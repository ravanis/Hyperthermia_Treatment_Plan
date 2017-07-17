% Used in binary operations to handle priority order, given two instances
% from different classes chooses which class handles the operation. The
% class with the highest priority will handle the operation
classdef (Abstract) AbstractOctreePriority
    methods
        % Priority wrappers for binary operators
        function output = plus(a, b)
            output = Yggdrasil.AbstractOctreePriority.prio(a, b, @a.plus_, @b.plus_);
        end
        
        function output = minus(a, b)
            output = Yggdrasil.AbstractOctreePriority.prio(a, b, @a.minus_, @b.minus_);
        end
        function output = times(a, b)
            output = Yggdrasil.AbstractOctreePriority.prio(a, b, @a.times_, @b.times_);
        end

        function output = mtimes(a, b)
            output = Yggdrasil.AbstractOctreePriority.prio(a, b, @a.mtimes_, @b.mtimes_);
        end
        function output = mrdivide(a, b)
            output = Yggdrasil.AbstractOctreePriority.prio(a, b, @a.mrdivide_, @b.mrdivide_);
        end
        function output = rdivide(a, b)
            output = Yggdrasil.AbstractOctreePriority.prio(a, b, @a.rdivide_, @b.rdivide_);
        end

        function output = ne(a, b)
            output = Yggdrasil.AbstractOctreePriority.prio(a, b, @a.ne_, @b.ne_);
        end
        function output = eq(a, b)
            output = Yggdrasil.AbstractOctreePriority.prio(a, b, @a.eq_, @b.eq_);
        end
        function output = and(a, b)
            output = Yggdrasil.AbstractOctreePriority.prio(a, b, @a.and_, @b.and_);
        end
        function output = or(a, b)
            output = Yggdrasil.AbstractOctreePriority.prio(a, b, @a.or_, @b.or_);
        end

        function output = gt(a, b)
            output = Yggdrasil.AbstractOctreePriority.prio(a, b, @a.gt_, @b.gt_);
        end
        function output = lt(a, b)
            output = Yggdrasil.AbstractOctreePriority.prio(a, b, @a.lt_, @b.lt_);
        end
        function output = ge(a, b)
            output = Yggdrasil.AbstractOctreePriority.prio(a, b, @a.ge_, @b.ge_);
        end
        function output = le(a, b)
            output = Yggdrasil.AbstractOctreePriority.prio(a, b, @a.le_, @b.le_);
        end

        function output = scalar_prod_integral(a, b)
            output = Yggdrasil.AbstractOctreePriority.prio(a, b, @a.scalar_prod_integral_, @b.scalar_prod_integral_);
        end
        function output = scalar_prod(a, b)
            output = Yggdrasil.AbstractOctreePriority.prio(a, b, @a.scalar_prod_, @b.scalar_prod_);
        end
        function output = weight(a, b)
            output = Yggdrasil.AbstractOctreePriority.prio(a, b, @a.weight_, @b.weight_);
        end
        
    end
    methods (Static = true)
        % Call function handle with highest priority
        output = prio(a, b, a_handle, b_handle)
    end
        
    methods (Static = true, Abstract = true)
        % Return the priority value
        output = priority();
    end
    
    
    methods (Static = true)
                
        % Default implementaion of binary operators
        function output = plus_(a,b)
            error('Operator plus is not implemented.');
        end
        function output = minus_(a,b)
            error('Operator minus is not implemented.');
        end
        function output = times_(a,b)
            error('Operator times is not implemented.');
        end
        
        function output = mtimes_(a,b)
            error('Operator mtimes is not implemented.');
        end
        function output = mrdivide_(a,b)
            error('Operator mrdivide is not implemented.');
        end
        function output = rdivide_(a,b)
            error('Operator rdivide is not implemented.');
        end
        
        function output = ne_(a,b)
            error('Operator ne is not implemented.');
        end
        function output = eq_(a,b)
            error('Operator eq is not implemented.');
        end
        function output = and_(a,b)
            error('Operator and is not implemented.');
        end
        function output = or_(a,b)
            error('Operator or is not implemented.');
        end

        function output = gt_(a,b)
            error('Operator gt is not implemented.');
        end
        function output = lt_(a,b)
            error('Operator lt is not implemented.');
        end
        function output = ge_(a,b)
            error('Operator ge is not implemented.');
        end
        function output = le_(a,b)
            error('Operator le is not implemented.');
        end
        
        function output = scalar_prod_integral_(a,b)
            error('Operator scalar_prod_integral is not implemented.');
        end
        function output = scalar_prod_(a,b)
            error('Operator scalar_prod is not implemented.');
        end
        function output = weight_(a,b)
            error('Operator weight is not implemented.');
        end
    end
end
