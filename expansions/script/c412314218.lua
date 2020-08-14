--created by Jake, coded by Glitchy
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_WARRIOR),1)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(cid.wpcon)
	e1:SetTarget(cid.wptg)
	e1:SetOperation(cid.wpop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cid.negcon)
	e2:SetTarget(cid.negtg)
	e2:SetOperation(cid.negop)
	c:RegisterEffect(e2)
end
function cid.pmfilter(c)
	return c:IsSetCard(0x613) and c:IsType(TYPE_MONSTER)
end
function cid.wpfilter(c)
	return c:IsFacedown() or (c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_WARRIOR))
end
function cid.negfilter(c)
	return c:IsSetCard(0x613) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function cid.wpcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:GetMaterial():IsExists(cid.pmfilter,1,nil)
end
function cid.wptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(cid.wpfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function cid.wpop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cid.wpfilter,tp,0,LOCATION_MZONE,nil)
	Duel.Destroy(g,REASON_EFFECT)
end
function cid.negcon(e,tp,eg,ep,ev,re,r,rp)
	if ep~=1-tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainDisablable(ev) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE) and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-#tg>0
end
function cid.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.negfilter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function cid.negop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(cid.negfilter,tp,LOCATION_GRAVE,0,2,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.negfilter),tp,LOCATION_GRAVE,0,2,2,nil)
	if #tg>0 then
		Duel.HintSelection(tg)
		Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
		local og=Duel.GetOperatedGroup()
		if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		if ct==#og then
			Duel.NegateEffect(ev)
		end
	end
end