--[[
Vacuous Keeper
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsStats,0,0),5,2,nil,nil,99)
	--[[If this card is Xyz Summoned, or if a card(s) is banished from your GY while you control this monster (in which case this is a Quick Effect): You can banish cards your opponent controls
	face-down, up to the number of materials attached to this card, and if you do, your opponent loses 500 LP for each card banished this way.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.XyzSummonedCond,
		nil,
		s.rmtg,
		s.rmop
	)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetLabelObject(aux.AddThisCardInMZoneAlreadyCheck(c))
	e2:SetCondition(aux.AlreadyInRangeEventCondition(s.cfilter))
	c:RegisterEffect(e2)
	--[[During your opponent's Main Phase 1 (Quick Effect): You can detach 1 material from this card; make 1 monster you control with 0 original ATK/DEF (that is not already affected by "Vacuous
	Keeper") gain the following effect.
	● At the start of the Damage Step, if this card battles: Your opponent immediately loses 200 LP for each of their banished cards.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetHintTiming(TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e3:SetFunctions(
		aux.MainPhaseCond(1,1),
		aux.DetachSelfCost(),
		s.efftg,
		s.effop
	)
	c:RegisterEffect(e3)
	--[[Once per turn, during your Standby Phase (Quick Effect): Activate this effect; if this card has materials, attach 3 banished cards to it as materials, otherwise return it to the Extra Deck,
	and if you do, draw 1 card.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,4)
	e3:SetCategory(CATEGORY_TOEXTRA|CATEGORY_DRAW)
	e3:SetCustomCategory(CATEGORY_ATTACH)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:OPT(true)
	e3:SetHintTiming(TIMING_STANDBY_PHASE)
	e3:SetFunctions(
		aux.StandbyPhaseCond(0),
		nil,
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	c:RegisterEffect(e4)
end

--E1
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=c:GetOverlayCount()
	local g=Duel.Group(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil,tp,POS_FACEDOWN)
	if chk==0 then return ct>0 and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local ct=c:GetOverlayCount()
	local g=Duel.Group(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil,tp,POS_FACEDOWN)
	if ct<=0 or #g<=0 then return end
	Duel.HintMessage(tp,HINTMSG_REMOVE)
	local rg=g:Select(tp,1,ct,nil)
	Duel.HintSelection(rg)
	if Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)>0 then
		local n=Duel.GetGroupOperatedByThisEffect(e):FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
		if n>0 then
			Duel.LoseLP(1-tp,n*500)
		end
	end
end

--E2
function s.cfilter(c,_,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end

--E3
function s.efilter(c)
	return c:IsFaceup() and c:IsBaseStats(0,0) and not c:HasFlagEffect(id)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.efilter,tp,LOCATION_MZONE,0,1,nil)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_FACEUP,false,tp,s.efilter,tp,LOCATION_MZONE,0,1,1,nil)
	if Duel.Highlight(g) then
		local tc=g:GetFirst()
		local c=e:GetHandler()
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
		local e1=Effect.CreateEffect(tc)
		e1:SetDescription(id,3)
		e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_BATTLE_START)
		e1:SetFunctions(nil,nil,nil,s.lpop)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		aux.GainEffectType(tc,c)
	end
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetBanishmentCount(1-tp)
	if ct>0 then
		Duel.LoseLP(1-tp,ct*200)
	end
end

--E4
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local infocon=c:GetOverlayCount()>0 and Duel.IsExists(false,Card.IsCanBeAttachedTo,tp,LOCATION_REMOVED,LOCATION_REMOVED,3,nil,c,e,tp,REASON_EFFECT)
	Duel.SetConditionalCustomOperationInfo(infocon,0,CATEGORY_ATTACH,nil,3,PLAYER_ALL,LOCATION_REMOVED)
	Duel.SetConditionalOperationInfo(not infocon,0,CATEGORY_TOEXTRA,c,1,0,0)
	Duel.SetConditionalOperationInfo(not infocon,0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local g=Duel.Group(Card.IsCanBeAttachedTo,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,c,e,tp,REASON_EFFECT)
	local chk=c:GetOverlayCount()>0 and #g>=3
	if chk then
		Duel.HintMessage(tp,HINTMSG_ATTACH)
		local tg=g:Select(tp,3,3,nil)
		Duel.HintSelection(tg)
		Duel.Attach(tg,c,false,e,REASON_EFFECT,tp)
	else
		if Duel.ShuffleIntoDeck(c,nil,LOCATION_EXTRA)>0 then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end