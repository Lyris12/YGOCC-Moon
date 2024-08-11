--[[
Flood of Sorrow, Scarlet Red Silence
Diluvio di Dolore, Silenzio Rosso Scarlatto
Card Author: Swag
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If you control a Level/Future 5 or higher "Scarlet Red" monster: You can discard 1 other card; Special Summon this card from your hand or GY,
	but place it on top of your Deck during the End Phase.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:HOPT()
	e1:SetFunctions(
		s.condition,
		aux.DiscardCost(nil,1,1,true),
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	--[[If this card is Special Summoned: You can add 1 "Scarlet Red" card from your GY to your hand, then you can place 1 of your Zombie monsters that is banished or in the GY on top of your Deck.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(
		nil,
		nil,
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e2)
	--[[You can target up to 3 Level 6 or lower "Scarlet Red" monsters with different names in your GY; place them on the bottom of the Deck in any order, and if you do,
	you can negate the effects of 1 face-up card your opponent controls until the end of the turn.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_TODECK|CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetFunctions(
		nil,
		nil,
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e3)
end

--E1
function s.cfilter(c,e,tp,eg,ep,ev,re,r,rp,obj,event)
	return c:IsFaceup() and c:IsSetCard(ARCHE_SCARLET_RED) and (c:IsLevelAbove(5) or c:IsFutureAbove(5))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(id,3)
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE|PHASE_END)
		e1:OPT()
		e1:SetCondition(s.descon)
		e1:SetOperation(s.desop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	if c:GetFlagEffect(id)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
end

--E2
function s.thfilter(c)
	return c:IsSetCard(ARCHE_SCARLET_RED) and c:IsAbleToHand()
end
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToDeck()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GB)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc and Duel.SearchAndCheck(tc) then
		local g=Duel.Group(s.tdfilter,tp,LOCATION_GB,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,STRING_ASK_TO_DECK) then
			Duel.ShuffleHand(tp)
			Duel.HintMessage(tp,HINTMSG_TODECK)
			local tg=g:Select(tp,1,1,nil)
			if #tg>0 then
				Duel.HintSelection(tg)
				Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)
			end
		end
	end
end

--E3
function s.tdfilter2(c,e)
	return c:IsMonster() and c:HasLevel() and c:IsLevelBelow(6) and c:IsSetCard(ARCHE_SCARLET_RED) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter2(chkc,e)
	end
	local g=Duel.Group(s.tdfilter2,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then
		return aux.SelectUnselectGroup(g,e,tp,1,3,aux.dncheck,0)
	end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,3,aux.dncheck,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(tg)
	Duel.SetCardOperationInfo(tg,CATEGORY_TODECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.disfilter(c,e)
	return aux.NegateAnyFilter(c) and c:IsCanBeDisabledByEffect(e)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g>0 and aux.PlaceCardsOnDeckBottom(tp,g,REASON_EFFECT)>0 then
		local ng=Duel.Group(s.disfilter,tp,0,LOCATION_ONFIELD,nil,e)
		if #ng>0 and Duel.SelectYesNo(tp,STRING_ASK_DISABLE) then
			Duel.HintMessage(tp,HINTMSG_DISABLE)
			local tg=ng:Select(tp,1,1,nil)
			Duel.HintSelection(tg)
			Duel.Negate(tg:GetFirst(),e,RESET_PHASE|PHASE_END,false,false,TYPE_NEGATE_ALL)
		end
	end
end