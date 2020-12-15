--created & coded by Lyris, art from Cardfight!! Vanguard's "Barking Cerberus"
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCondition(function(e) return e:GetHandler():GetSummonLocation()==LOCATION_OVERLAY and e:GetHandler():GetSummonPlayer()==e:GetHandler():GetControler() end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0xc74) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		and Duel.GetOverlayGroup(tp,1,1):IsExists(s.filter,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_OVERLAY)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.GetOverlayGroup(tp,1,1):FilterSelect(tp,s.filter,1,1,nil,e,tp)
	if #g==0 then return end
	local tc=g:GetFirst():GetOverlayTarget()
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 then
		Duel.BreakEffect()
		Duel.DisableShuffleCheck()
		Duel.Overlay(tc,Duel.GetDecktopGroup(tp,1))
	end
end
