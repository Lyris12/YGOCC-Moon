--[[
Vacuous Master
Maestro Vacuo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_POWER_VACUUM_ZONE)
	c:EnableReviveLimit()
	aux.AddSynchroMixProcedure(c,s.tunerfilter,s.tunerfilter,s.tunerfilter,aux.NonTuner(nil),1,1)
	--[[If this card is Synchro Summoned, or if a "Vacuous" monster(s) is banished while you control this card (in which case this is a Quick Effect): You can target 1 monster you control and 1
	monster your opponent controls; shuffle both targets into the Deck, and if you do, your opponent must send the top 2 cards of their Deck to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.SynchroSummonedCond,
		nil,
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e1)
	local e1q=Effect.CreateEffect(c)
	e1q:SetDescription(id,0)
	e1q:SetCategory(CATEGORY_TODECK|CATEGORY_DECKDES)
	e1q:SetType(EFFECT_TYPE_QUICK_O)
	e1q:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1q:SetCode(EVENT_REMOVE)
	e1q:SetRange(LOCATION_MZONE)
	e1q:SHOPT()
	e1q:SetLabelObject(aux.AddThisCardInMZoneAlreadyCheck(c))
	e1q:SetFunctions(
		aux.AlreadyInRangeEventCondition(s.cfilter),
		nil,
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e1q)
	--[[You can Tribute 1 other monster with 0 ATK/DEF; add 1 "Vacuous" monster or 1 card that mentions "Power Vacuum Zone" from your Deck or GY to your hand, except a card with the same name as the
	monster Tributed to activate this effect.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(
		nil,
		nil,
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e2)
	--[[While you control "Power Vacuum Zone", your opponent cannot activate cards or effects in their GY or banishment, except during their Main Phase 2.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.actlimcond)
	e3:SetValue(s.actlim)
	c:RegisterEffect(e3)
end
function s.tunerfilter(c,sync)
	return aux.Tuner(aux.FilterEqualFunction(Card.GetBaseAttack,0))(c,sync)
end

--E1
function s.filter(c,e)
	return c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(ARCHE_VACUOUS)
end
function s.rescon(sg,e,tp,mg)
    return sg:FilterCount(Card.IsControler,nil,tp)==1
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local rg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then
		return aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0) and Duel.IsPlayerCanDiscardDeck(1-tp,2)
	end
	local tg=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
	local tc1=tg:Filter(Card.IsControler,nil,tp):GetFirst()
	tc1:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
	Duel.SetTargetCard(tg)
	Duel.SetCardOperationInfo(tg,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,2)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards():Filter(Card.IsAbleToDeck,nil)
	for tc in aux.Next(g) do
		local p=tc:HasFlagEffect(id) and tp or 1-tp
		if not tc:IsControler(p) then
			return
		end
	end
	if #g==2 and Duel.ShuffleIntoDeck(g)==2 then
		Duel.DiscardDeck(1-tp,2,REASON_RULE)
	end
end

--E2
function s.rlfilter(c,tp)
	return c:IsStats(0,0) and Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,c,c:GetCode())
end
function s.thfilter(c,...)
	return c:IsAbleToHand() and ((c:IsMonster() and c:IsSetCard(ARCHE_VACUOUS)) or c:Mentions(CARD_POWER_VACUUM_ZONE)) and not c:IsCode(...)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetReleaseGroup(tp):Filter(s.rlfilter,c,tp)
	if chk==0 then
		return e:IsCostChecked() and #g>0
	end
	local rg=g:FilterSelect(tp,s.rlfilter,1,1,c,tp)
	e:SetLabel(rg:GetFirst():GetCode())
	Duel.Release(rg,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e:GetLabel())
	if #g>0 then
		Duel.Search(g)
	end
end

--E3
function s.actlimcond(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_ZONE),tp,LOCATION_ONFIELD,0,1,nil) and not Duel.IsMainPhase(1-tp,2)
end
function s.actlim(e,re,tp)
	return re:GetActivateLocation()&(LOCATION_GRAVE|LOCATION_REMOVED)>0 and re:GetHandler():IsControler(tp)
end