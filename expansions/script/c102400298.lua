--created & coded by Lyris
--半物質の曇
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
function s.cfilter(c,e,tp)
	local p=c:GetOwner()
	if not Duel.IsExistingMatchingCard(Card.IsAbleToRemove,p,LOCATION_ONFIELD,0,1,nil,tp) then return false end
	if not c:IsControler(tp) and c:IsFacedown() then return Duel.GetLocationCount(tp,LOCATION_MZONE,p)>0
		and Duel.IsPlayerCanSpecialSummon(tp,0,POS_FACEDOWN_DEFENSE,p)
		and Duel.GetLocationCount(tp,LOCATION_SZONE,p)>0 and Duel.IsPlayerCanSSet(tp,c) end
	if c:IsType(TYPE_MONSTER) then return Duel.GetLocationCount(tp,LOCATION_MZONE,p)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,p)
	else return Duel.GetLocationCount(tp,LOCATION_SZONE,p)>0 and c:IsSSetable() end
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.cfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp):GetFirst()
	if tc:IsFacedown() or tc:IsType(TYPE_MONSTER) then e:SetCategory(CATEGORY_SPECIAL_SUMMON)
	else e:SetCategory(0) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,Duel.GetMatchingGroup(Card.IsAbleToRemove,tc:GetOwner(),LOCATION_ONFIELD,0,nil,tp),1,0,0)
	if tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0) end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local p=tc:GetOwner()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	if Duel.Remove(Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,p,LOCATION_ONFIELD,0,1,1,nil,tp),POS_FACEUP,REASON_EFFECT)==0 then return end
	local fu=tc:IsFaceup()
	if tc:IsType(TYPE_MONSTER) then
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 and fu then Duel.ConfirmCards(1-tp,tc) end
	else Duel.SSet(tp,tc,p,fu) end
end
