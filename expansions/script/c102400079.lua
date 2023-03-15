--created & coded by Lyris, art from Shadowverse's "Lapis, Glorious Seraph"
--剣主のアドバンテージ
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,chk)
	if not (c:IsSetCard(0xbb2) and c:IsAbleToHand()) then return false end
	if chk then return true end
	return c:IsType(TYPE_MONSTER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)) end
	Duel.SetOperationInfo(0,CATEGORY_SEARCH,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE))
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
end
