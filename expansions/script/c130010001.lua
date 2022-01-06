--Automate ID
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--synchro summon
	aux.AddSynchroMixProcedure(c,s.matfilter1,nil,nil,aux.NonTuner(Card.IsSetCard,0x301),1,99)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_RACE)
	e2:SetRange(0xff)
	e2:SetValue(RACE_SPELLCASTER)
	c:RegisterEffect(e2)
	--cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	c:RegisterEffect(e3)
	--negate
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(3,id)
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
function s.matfilter1(c)
	return c:IsType(TYPE_TUNER) or c:IsSetCard(0x301)
end
function s.indcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroup(tp,LOCATION_GRAVE,0):GetClassCount(Card.GetCode,nil)>=8
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.filter1(c,tp)
	return c:IsSetCard(0x301) and c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_GRAVE,0,1,nil,tp,c:GetCode())
end
function s.filter2(c,tp,code)
	return c:IsSetCard(0x301) and c:IsAbleToRemoveAsCost() and not c:IsCode(code)
		and Duel.IsExistingMatchingCard(s.filter3,tp,LOCATION_GRAVE,0,1,nil,code,c:GetCode())
end
function s.filter3(c,code1,code2)
	return c:IsSetCard(0x301) and c:IsAbleToRemoveAsCost() and not c:IsCode(code1,code2)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_GRAVE,0,1,nil,tp) end
	local tc1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_GRAVE,0,nil,tp):GetFirst()
	local tc2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_GRAVE,0,nil,tp,tc1:GetCode()):GetFirst()
	local tc3=Duel.SelectMatchingCard(tp,s.filter3,tp,LOCATION_GRAVE,0,nil,tc1:GetCode(),tc2:GetCode()):GetFirst()
	Duel.Remove(Group.FromCards(tc1,tc2,tc3),POS_FACEUP,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.nbcon(tp,re) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
