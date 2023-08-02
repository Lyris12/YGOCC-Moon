--Trappit Camp Worksite
--Campo Cantiere dei Trappolanigli
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:Activation(true)
	--[[Your opponent cannot activate cards or effects when you Normal or Flip Summon a monster.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(s.limcon)
	e1:SetOperation(s.limop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_MSET)
	e3:SetCondition(s.limcon_set)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_CHAIN_END)
	e4:SetOperation(s.limop2)
	c:RegisterEffect(e4)
	--[[Each time a Normal Trap is activated, monsters the activator's opponent currently controls lose 500 ATK/DEF immediately after it resolves.]]
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_FZONE)
	e5:SetOperation(s.regop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAIN_SOLVED)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCondition(s.atkcon)
	e6:SetOperation(s.atkop)
	c:RegisterEffect(e6)
	--[[Once per turn, if a monster(s) is Normal or Flip Summoned, or Normal Set (except during the Damage Step): You can target 1 card on the field; Set it, or, if it is already Set, destroy it.]]
	local e7=Effect.CreateEffect(c)
	e7:Desc(0)
	e7:SetCategory(CATEGORY_POSITION|CATEGORY_DESTROY)
	e7:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_SUMMON_SUCCESS)
	e7:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e7:SetRange(LOCATION_FZONE)
	e7:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e7:SetCondition(s.condition)
	e7:SetTarget(s.target)
	e7:SetOperation(s.operation)
	c:RegisterEffect(e7)
	local e8=e7:FlipSummonEventClone(c)
	local e9=e7:Clone()
	e9:SetCode(EVENT_MSET)
	e9:SetCondition(s.condition_set)
	c:RegisterEffect(e9)
end
--FILTERS E1
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_NORMAL)
end
--E1
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(Card.IsSummonType,tp,0,LOCATION_MZONE,1,nil,SUMMON_TYPE_SPECIAL) and eg:IsExists(Card.IsSummonPlayer,1,nil,tp)
end
function s.limcon_set(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(Card.IsSummonType,tp,0,LOCATION_MZONE,1,nil,SUMMON_TYPE_SPECIAL) and eg:IsExists(s.cfilter,1,nil,tp)
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentChain()==0 then
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
	end
end
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:HasFlagEffect(id) then
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	c:ResetFlagEffect(id)
end
function s.chainlm(e,rp,tp)
	return tp==rp
end

--E2
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and not re:IsActiveType(TYPE_CONTINUOUS|TYPE_COUNTER) then
		e:GetHandler():RegisterFlagEffect(id+100,RESET_EVENT|(RESETS_STANDARD&(~RESET_TURN_SET))|RESET_CHAIN,0,1)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:HasFlagEffect(id+100) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and not re:IsActiveType(TYPE_CONTINUOUS|TYPE_COUNTER)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local g=Duel.Group(Card.IsFaceup,rp,0,LOCATION_MZONE,nil)
	if #g>0 then
		for tc in aux.Next(g) do
			tc:UpdateATKDEF(-500,-500,true,e:GetHandler())
		end
	end
end

--FILTERS E3
function s.cfilter2(c,tp)
	return c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_NORMAL)
end
function s.setfilter(c)
	return c:IsFacedown() or ((c:IsLocation(LOCATION_MZONE) and c:IsCanTurnSet()) or (not c:IsLocation(LOCATION_MZONE) and c:IsSSetable(true)))
end
--E3
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,tp)
end
function s.condition_set(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter2,1,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.setfilter(chkc) end
	if chk==0 then
		return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	end
	local g=Duel.Select(HINTMSG_OPERATECARD,true,tp,s.setfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		if tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) then
			Duel.SetCardOperationInfo(g,CATEGORY_POSITION)
		elseif tc:IsFacedown() then
			Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
		end
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		if tc:IsFaceup() then
			if tc:IsLocation(LOCATION_MZONE) then
				Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
			else
				Duel.ChangePosition(tc,POS_FACEDOWN)
				tc:SetStatus(STATUS_ACTIVATE_DISABLED,false)
				tc:SetStatus(STATUS_SET_TURN,true)
				Duel.RaiseSingleEvent(tc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
				Duel.RaiseEvent(tc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
			end
		else
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end