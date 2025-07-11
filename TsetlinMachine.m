classdef TsetlinMachine
    properties
        number_of_classes
        number_of_clauses
        number_of_features
        s
        number_of_states
        threshold
        boost_true_positive_feedback
        ta_state
        clause_count
        clause_sign
        clause_output
        class_sum
        feedback_to_clauses
    end

    methods
        function obj = TsetlinMachine(number_of_classes, number_of_clauses, number_of_features, number_of_states, s, threshold, boost_true_positive_feedback)
            if nargin < 7
                boost_true_positive_feedback = 0;
            end

            obj.number_of_classes = number_of_classes;
            obj.number_of_clauses = number_of_clauses;
            obj.number_of_features = number_of_features;
            obj.number_of_states = number_of_states;
            obj.s = s;
            obj.threshold = threshold;
            obj.boost_true_positive_feedback = boost_true_positive_feedback;

            % Initialize TA state
            obj.ta_state = randi([number_of_states, number_of_states + 1], number_of_clauses, number_of_features, 2);

            % Initialize Clause Sign and Count
            obj.clause_count = zeros(number_of_classes, 1);
            obj.clause_sign = zeros(number_of_classes, floor(number_of_clauses / number_of_classes), 2);
            obj.clause_output = zeros(number_of_clauses, 1);
            obj.class_sum = zeros(number_of_classes, 1);
            obj.feedback_to_clauses = zeros(number_of_clauses, 1);

            % Set up the Tsetlin Machine structure
            for i = 1:number_of_classes
                for j = 1:floor(number_of_clauses / number_of_classes)
                    obj.clause_sign(i, obj.clause_count(i) + 1, 1) = (i - 1) * floor(number_of_clauses / number_of_classes) + j;
                    if mod(j, 2) == 1
                        obj.clause_sign(i, obj.clause_count(i) + 1, 2) = 1;
                    else
                        obj.clause_sign(i, obj.clause_count(i) + 1, 2) = -1;
                    end
                    obj.clause_count(i) = obj.clause_count(i) + 1;
                end
            end
        end

        function obj = calculate_clause_output(obj, X, predict)
            if nargin < 3
                predict = 0;
            end

            obj.clause_output = ones(obj.number_of_clauses, 1);

            for j = 1:obj.number_of_clauses
                all_exclude = 1;
                for k = 1:obj.number_of_features
                    action_include = obj.action(obj.ta_state(j, k, 1));
                    action_include_negated = obj.action(obj.ta_state(j, k, 2));

                    if action_include == 1 || action_include_negated == 1
                        all_exclude = 0;
                    end

                    if (action_include == 1 && X(k) == 0) || (action_include_negated == 1 && X(k) == 1)
                        obj.clause_output(j) = 0;
                        break;
                    end
                end

                if predict == 1 && all_exclude == 1
                    obj.clause_output(j) = 0;
                end
            end
        end

        function obj = sum_up_class_votes(obj)
            obj.class_sum = zeros(obj.number_of_classes, 1);

            for target_class = 1:obj.number_of_classes
                for j = 1:obj.clause_count(target_class)
                    clause_index = obj.clause_sign(target_class, j, 1);
                    obj.class_sum(target_class) = obj.class_sum(target_class) + obj.clause_output(clause_index) * obj.clause_sign(target_class, j, 2);
                end

                obj.class_sum(target_class) = min(max(obj.class_sum(target_class), -obj.threshold), obj.threshold);
            end
        end

        function action_value = action(obj, state)
            if state <= obj.number_of_states
                action_value = 0;
            else
                action_value = 1;
            end
        end

        function predicted_class = predict(obj, X)
            obj = obj.calculate_clause_output(X, 1);
            obj = obj.sum_up_class_votes();
            [~, predicted_class] = max(obj.class_sum);
            predicted_class = predicted_class - 1;
        end

    function accuracy = evaluate(obj, X, y)
        num_samples = size(X, 1);
        correct_predictions = 0;

        for i = 1:num_samples
            predicted_class = obj.predict(X(i, :));
            if predicted_class == y(i)         
                correct_predictions = correct_predictions + 1;
            end
        end
        accuracy = correct_predictions / num_samples;
    end

    function obj = update(obj, X, target_class)
        classes = 1:obj.number_of_classes;
        classes(target_class) = [];
        negative_target_class = classes(randi(length(classes)));
    
        obj = obj.calculate_clause_output(X, 0);
        obj = obj.sum_up_class_votes();
    
        obj.feedback_to_clauses = zeros(obj.number_of_clauses, 1);
    
        for j = 1:size(obj.clause_sign, 2)
            clause_idx = obj.clause_sign(target_class, j, 1);
            clause_sign = obj.clause_sign(target_class, j, 2);
            if rand() <= (1 / (obj.threshold * 2)) * (obj.threshold - obj.class_sum(target_class))
                obj.feedback_to_clauses(clause_idx) = clause_sign;
            end
        end
    
        for j = 1:size(obj.clause_sign, 2)
            clause_idx = obj.clause_sign(negative_target_class, j, 1);
            clause_sign = obj.clause_sign(negative_target_class, j, 2);
            if rand() <= (1 / (obj.threshold * 2)) * (obj.threshold + obj.class_sum(negative_target_class))
                obj.feedback_to_clauses(clause_idx) = -clause_sign;
            end
        end
    
        for j = 1:obj.number_of_clauses
            if obj.feedback_to_clauses(j) > 0
                if obj.clause_output(j) == 0
                    for k = 1:obj.number_of_features
                        if rand() <= 1.0 / obj.s && obj.ta_state(j, k, 1) > 1
                            obj.ta_state(j, k, 1) = obj.ta_state(j, k, 1) - 1;
                        end
                        if rand() <= 1.0 / obj.s && obj.ta_state(j, k, 2) > 1
                            obj.ta_state(j, k, 2) = obj.ta_state(j, k, 2) - 1;
                        end
                    end
                else
                    for k = 1:obj.number_of_features
                        if X(k) == 1
                            if obj.boost_true_positive_feedback == 1 || rand() <= (obj.s - 1) / obj.s
                                if obj.ta_state(j, k, 1) < obj.number_of_states * 2
                                    obj.ta_state(j, k, 1) = obj.ta_state(j, k, 1) + 1;
                                end
                            end
                            if rand() <= 1.0 / obj.s && obj.ta_state(j, k, 2) > 1
                                obj.ta_state(j, k, 2) = obj.ta_state(j, k, 2) - 1;
                            end
                        else
                            if obj.boost_true_positive_feedback == 1 || rand() <= (obj.s - 1) / obj.s
                                if obj.ta_state(j, k, 2) < obj.number_of_states * 2
                                    obj.ta_state(j, k, 2) = obj.ta_state(j, k, 2) + 1;
                                end
                            end
                            if rand() <= 1.0 / obj.s && obj.ta_state(j, k, 1) > 1
                                obj.ta_state(j, k, 1) = obj.ta_state(j, k, 1) - 1;
                            end
                        end
                    end
                end
    
            elseif obj.feedback_to_clauses(j) < 0 && obj.clause_output(j) == 1
                for k = 1:obj.number_of_features
                    include = obj.action(obj.ta_state(j, k, 1));
                    include_negated = obj.action(obj.ta_state(j, k, 2));
    
                    if X(k) == 0 && include == 0 && obj.ta_state(j, k, 1) < obj.number_of_states * 2
                        obj.ta_state(j, k, 1) = obj.ta_state(j, k, 1) + 1;
                    elseif X(k) == 1 && include_negated == 0 && obj.ta_state(j, k, 2) < obj.number_of_states * 2
                        obj.ta_state(j, k, 2) = obj.ta_state(j, k, 2) + 1;
                    end
                end
            end
        end
    end

        function obj = fit(obj, X, y, epochs)
            for epoch = 1:epochs
                for i = 1:size(X, 1)
                    target_class = y(i) + 1;
                    if target_class > obj.number_of_classes
                        error('target_class=%d exceeds number_of_classes=%d', target_class, obj.number_of_classes);
                    end
                    obj = obj.update(X(i, :), target_class);
                end
            end
        end

    end
end
