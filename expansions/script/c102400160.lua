--created & coded by Lyris, art from Shadowverse's "Lightning Blast"
--襲雷弾
local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigSkillType(c)
	aux.EDSkillProperties(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.skillcon_skill)
	e1:SetOperation(s.skillop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetOperation(s.skillop2)
	c:RegisterEffect(e2)
end
function s.skillcon_skill(e,tp,eg,ep,ev,re,r,rp)
	return aux.skillcon(e) and rp~=tp
end
function s.filter(c)
	return c:IsSetCard(0x7c4) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and (c:IsFaceup() and c:IsType(TYPE_PENDULUM) or c:IsLocation(LOCATION_GRAVE))
end
function s.skillop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
	if Duel.SendtoDeck(g,nil,2,REASON_EFFECT)==0 or not g:GetFirst():IsLocation(LOCATION_DECK) then return end
	Duel.ShuffleDeck(tp)
	Duel.RegisterFlagEffect(tp,1,RESET_CHAIN,0,1)
end
function s.cfilter(c)
	return c:GetOriginalType()&TYPE_MONSTER~=0 and c:IsSetCard(0x7c4) and c:IsDestructable()
end
function s.skillop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,1)==0 or Duel.GetFlagEffect(tp,id)>=3 then return end
	local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
	local g2=Duel.GetMatchingGroup(Card.IsDestructable,tp,0,LOCATION_ONFIELD,nil)
	if #g1==0 or #g2==0 or not Duel.SelectEffectYesNo(tp,e:GetHandler()) then return end
	local g=g1:Select(tp,1,1,nil)+g2:Select(tp,1,1,nil)
	Duel.Destroy(g,REASON_EFFECT)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
