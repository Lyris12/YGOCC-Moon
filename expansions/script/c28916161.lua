--This file was automatically coded by Kinny's Numeron Code~!
local ref=_G['c'..28916161]
local id=28916161
function ref.initial_effect(c)
	--Effect 0
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e0:SetCode(EVENT_SUMMON_SUCCESS)
	e0:SetCountLimit(1,289161610)
	e0:SetCondition(ref.sscon)
	e0:SetTarget(ref.target0)
	e0:SetOperation(ref.operation0)
	c:RegisterEffect(e0)
	--Effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,289161611)
	e1:SetTarget(ref.target1)
	e1:SetOperation(ref.operation1)
	c:RegisterEffect(e1)
end
function ref.filterE0P0(c,e,tp)
	return c:IsCode(28916160) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function ref.filterE1P0(c)
	return c:IsFacedown()
end
function ref.filterE1P1(c)
	return c:IsAbleToRemove()
end
function ref.sscfilter(c,tc)
	return c:IsFaceup() and c:IsSetCard(1856)
		and c:GetCode()~=tc:GetCode()
end
function ref.sscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(ref.sscfilter,tp,LOCATION_ONFIELD,0,1,c,c)
end
function ref.target0(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(ref.filterE0P0,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
function ref.operation0(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local g0 = Duel.SelectMatchingCard(tp,ref.filterE0P0,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g0<=0 then return end
	Duel.SpecialSummon(g0,0,tp,tp,false,false,POS_FACEUP)
end
function ref.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFacedown() and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(ref.filterE1P0,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g0 = Duel.SelectTarget(tp,ref.filterE1P0,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g0,#g0,0,0)
end
function ref.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g0 = Duel.GetFirstTarget()
	if not g0 or not g0:IsRelateToEffect(e) then return end
	if Duel.ChangePosition(g0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE)~=0 then
		if Duel.IsExistingMatchingCard(ref.filterE1P1,tp,0,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local g1 = Duel.SelectMatchingCard(tp,ref.filterE1P1,tp,0,LOCATION_ONFIELD,1,1,nil)
			if #g1>=0 then
				Duel.Remove(g1,POS_FACEDOWN,REASON_EFFECT)
			end
		end
	end
end
