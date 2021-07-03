--This file was automatically coded by Kinny's Numeron Code~!
--And Kinny. Kinny fixed it.
local ref=_G['c'..28915122]
local id=28915122
function ref.initial_effect(c)
	--Convergent Evolute
	c:SetSPSummonOnce(id)
	aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
	aux.AddEvoluteProc(c,'Convergent',0,ref.matfilter1,2)
	--Effect 0
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_REMOVE)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCondition(aux.cdrewcon)
	e0:SetTarget(ref.target0)
	e0:SetOperation(ref.operation0)
	c:RegisterEffect(e0)
	--Effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(ref.target1)
	e1:SetOperation(ref.operation1)
	c:RegisterEffect(e1)
end
function ref.matfilter1(c)
	return c:IsRace(RACE_PLANT) or c:IsSetCard(0x85a)
end

function ref.rmfilter(c)
	return c:IsType(TYPE_EXTRA) and c:IsAbleToRemove()
end
function ref.rmfilter2(c,rc)
	return (c:GetType()&rc:GetType())&TYPE_EXTRA~=0
end
function ref.rmfilter3(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
function ref.ssfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and not c:IsType(TYPE_EFFECT)
end
function ref.target0(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(ref.rmfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil) end
	if chkc then return ref.rmfilter(chkc) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and chkc:IsControler(tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HITNMSG_REMOVE)
	local g0 = Duel.SelectTarget(tp,ref.rmfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g0,tp,1,g0:GetFirst():GetLocation())
	--Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
	--Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD)
end
function ref.operation0(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		if Duel.IsExistingMatchingCard(ref.rmfilter2,1-tp,LOCATION_EXTRA,0,1,nil,tc) and Duel.SelectYesNo(1-tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HITNMSG_REMOVE)
			local g1 = Duel.SelectMatchingCard(1-tp,ref.rmfilter2,1-tp,LOCATION_EXTRA,0,1,1,nil,tc)
			Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HITNMSG_REMOVE)
			local g1=Duel.SelectMatchingCard(tp,ref.rmfilter3,tp,0,LOCATION_ONFIELD,1,2,nil)
			Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function ref.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function ref.operation1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2 = Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g2:GetCount()>0 then
		Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
	end
end
