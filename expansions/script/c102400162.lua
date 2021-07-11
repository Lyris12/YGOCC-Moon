--created by LeonDuvall of Discord, coded by Lyris, art from Cardfight!! Vanguard's "Quaking Heavenly Dragon, Astraios Dragon"
--YC.Orgの襲雷タクティシャン・ライリス
local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_DESTROYED)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCountLimit(1,id)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetCondition(s.spcon)
	e0:SetCost(s.cost)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	local e1=e0:Clone()
	e1:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,aux.FilterBoolFunction(Card.IsSetCard,0x7c4,0x96b))
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_DESTROY)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EVENT_ATTACK_ANNOUNCE)
	e0:SetCondition(s.descon)
	e0:SetTarget(s.destg)
	e0:SetOperation(s.desop)
	c:RegisterEffect(e0)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id-1)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.tdcon)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e4)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetTurnPlayer()~=tp and c:IsFaceup() and Duel.GetAttackTarget()==c
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.NegateAttack()
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.HintSelection(g)
		if #g>0 then
			Duel.BreakEffect()
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
function s.cfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x7c4,0x96b)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsSetCard),0x7c4,0x96b))
	Duel.RegisterEffect(e1,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.filter(c)
	return c:IsSetCard(0x7c4,0x96b) and c:IsAbleToDeck()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,3,nil) end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,nil)
	if #mg<3 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=mg:Select(tp,3,3,nil)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	if g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)==3 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
