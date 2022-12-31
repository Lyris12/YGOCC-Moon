--Space Time Breakdown
function c249000635.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c249000635.con)
	e1:SetOperation(c249000635.activate)
	c:RegisterEffect(e1)
	--summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c249000635.condition)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c249000635.target)
	e2:SetOperation(c249000635.operation)
	c:RegisterEffect(e2)
end
function c249000635.filter(c)
	return c:GetCode()==249000634 and c:IsFaceup()
end
function c249000635.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249000635.filter,e:GetHandler():GetControler(),LOCATION_ONFIELD,0,1,nil)
end
function c249000635.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=Duel.SelectOption(tp,21,24,aux.Stringid(249000635,1))
	local code=nil
	if op==0 then
		code=EFFECT_SKIP_SP
	elseif op==1 then
		code=EFFECT_SKIP_BP
	elseif op==2 then	 
		code=EFFECT_SKIP_M2
	end	
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(code)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	Duel.RegisterEffect(e1,tp)
end
function c249000635.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_FIELD)
end
function c249000635.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c249000635.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--disable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c249000635.distarget)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.Draw(tp,1,REASON_EFFECT)
end
function c249000635.distarget(e,c)
	return c:IsType(TYPE_FIELD)
end