--created by LeonDuvall, coded by Lyris
--Exodice Phich
local s,id,o=GetID()
function s.initial_effect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetCondition(s.sdcon)
	e1:SetCost(s.sdcost)
	e1:SetTarget(s.sdtg)
	e1:SetOperation(s.sdop)
	c:RegisterEffect(e1)
end
function s.spcon(e,tp,_,_,_,_,_,rp)
	return rp==1-tp
end
function s.sptg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,100)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.sfilter(c,e,tp)
	return c:IsSetCard(0xd18) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.spop(e,tp)
	if Duel.Damage(1-tp,100,REASON_EFFECT)<1 or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp),0,tp,tp,false,false,POS_FACEUP)
end
function s.sdcon(e,tp)
	local c=e:GetHandler()
	return c:IsSummonLocation(LOCATION_DECK+LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
function s.sdcost(e,_,_,_,_,_,_,_,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_FISH)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sdtg(e,tp,_,_,_,_,_,_,chk)
	local ft=Duel.GetMZoneCount(tp,e:GetHandler())
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,e,tp)
	if chk==0 then return ft>0 and #g>0 end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,ft,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,ft*100)
end
function s.sdop(e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<1 then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local g=Duel.GetMatchingGroup(tp,s.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	local ct=0
	if ft<#g then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		ct=Duel.SpecialSummon(g:Select(tp,ft,ft,nil),0,tp,tp,false,false,POS_FACEUP)
	else ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
	if ct<1 then return end
	Duel.Damage(tp,ct*100,REASON_EFFECT,true)
	Duel.Damage(1-tp,ct*100,REASON_EFFECT,true)
	Duel.RDComplete()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsAttribute),ATTRIBUTE_WATER))
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,Duel.GetTurnPlayer()==tp and 2 or 1)
	Duel.RegisterEffect(e1,tp)
end
