--Cascad Battleship - Halstein
--Script by XGlitchy30
function c31231318.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,c31231318.matfilter,1,1)
	c:EnableReviveLimit()
	--boost atk
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31231318,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,31231318)
	e1:SetCost(c31231318.spcost)
	e1:SetOperation(c31231318.spop)
	c:RegisterEffect(e1)
end
--filters
function c31231318.matfilter(c)
	return c:IsLinkSetCard(0x3233) and c:IsLinkType(TYPE_MONSTER) and not c:IsLinkCode(31231318)
end
function c31231318.spfilter(c,e,tp)
	return c:IsSetCard(0x3233) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--values
function c31231318.atktg(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
--boost atk
function c31231318.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	Duel.SendtoDeck(c,nil,0,REASON_COST)
end
function c31231318.spop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c31231318.atktg)
	e1:SetValue(300)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	Duel.RegisterEffect(e2,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c31231318.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) then
		if Duel.SelectYesNo(tp,aux.Stringid(31231318,1)) then
			local g=Duel.SelectMatchingCard(tp,c31231318.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			local sp=g:GetFirst()
			if sp then
				Duel.SpecialSummon(sp,0,tp,tp,false,false,POS_FACEUP)
			end
		else return end
	else return end
end