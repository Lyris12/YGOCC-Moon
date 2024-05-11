--[[
Punishment of Verdanse
Punizione di Verdanse
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	if not s.progressive_id then
		s.progressive_id=id
	else
		s.progressive_id=s.progressive_id+1
	end
	--[[When your opponent would Summon a monster(s), or when they activate a card or effect, while you control a "Verdanse" Ritual Monster or a DARK "Number" Xyz Monster that has material:
	Negate the Summon or activation, and if you do, shuffle that card into the Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON|CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:HOPT(true)
	e1:SetFunctions(
		s.dissumcon,
		nil,
		s.dissumtg,
		s.dissumop
	)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,1)
	e4:SetCategory(CATEGORY_NEGATE|CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetFunctions(
		s.discon,
		nil,
		s.distg,
		s.disop
	)
	c:RegisterEffect(e4)
	--[[If you Ritual Summon a "Verdanse" Ritual Monster(s) while this card is in your GY: You can banish this card from your GY; that monster(s) gains 1800 ATK/DEF, until the end of the next turn.]]
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id,EVENT_SPSUMMON_SUCCESS,s.atkfilter,id,LOCATION_GRAVE,nil,LOCATION_GRAVE,nil,id+100)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORIES_ATKDEF)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CUSTOM+s.progressive_id)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetFunctions(
		nil,
		aux.bfgcost,
		s.atktg,
		s.atkop
	)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c)
	if not c:IsFaceup() then return false end
	if c:IsType(TYPE_RITUAL) then
		return c:IsSetCard(ARCHE_VERDANSE)
	elseif c:IsType(TYPE_XYZ) then
		return c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK) and c:GetOverlayCount()>0
	end
	return false
end
function s.dissumfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsAbleToDeck()
end
function s.dissumcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and aux.NegateSummonCondition() and eg:IsExists(s.dissumfilter,1,nil,tp)
end
function s.dissumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(Card.IsSummonPlayer,nil,1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.dissumop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsSummonPlayer,nil,1-tp)
	Duel.NegateSummon(g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) and rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.ndcon(tp,re) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToChain(ev) then
		Duel.SetCardOperationInfo(eg,CATEGORY_TODECK)
	end
	if re:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(e:GetCategory()|CATEGORY_GRAVE_ACTION)
	else
		e:SetCategory(e:GetCategory()&~CATEGORY_GRAVE_ACTION)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToChain(ev) then
		rc:CancelToGrave()
		Duel.SendtoDeck(rc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

--E2
function s.atkfilter(c,e,tp,eg,ep,ev,re,r,rp,se)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:IsSetCard(ARCHE_VERDANSE) and c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_RITUAL)
		and (se==nil or c:GetReasonEffect()~=se)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(Card.IsCanChangeStats,nil,1800,1800)
	if chk==0 then return #g>0 end
	local tg=aux.SelectSimultaneousEventGroup(g,id+100)
	Duel.SetTargetCard(tg)
	Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,tg,#tg,0,0,1800)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards():Filter(Card.IsCanChangeStats,nil,1800,1800)
	for tc in aux.Next(g) do
		tc:UpdateATKDEF(1800,1800,{RESET_PHASE|PHASE_END,2},{c,true})
	end
end