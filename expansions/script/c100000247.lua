--[[
Clockwork Cascade
Cascata di Orologeria
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[Activate 1 of the following effects:
	● If you control an "Automatyrant" card: Send any number of cards from the top of your Deck to the GY, up to the number of cards your opponent controls;
	destroy an equal number of cards your opponent controls, then if you destroyed 3 or more cards this way, inflict 500 damage to your opponent for each card destroyed this way.
	● Add 1 Level 7 or higher "Automatyrant" monster from your Deck or GY to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetFunctions(nil,aux.DummyCost,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this card is sent from your hand or Deck to the GY, or if this Set card on the field is sent to the GY:
	You can pay half your LP; shuffle as many cards from your GY and banishment into the Deck as possible, and if you do, send the top 10 cards of your Deck to the GY.
	You must control a face-up "Automatyrant" monster to activate and resolve this effect.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,3)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetFunctions(s.tdcon,aux.PayHalfLPCost,s.tdtg,s.tdop)
	c:RegisterEffect(e2)
end
--E1
function s.validnum(i,tp)
	return Duel.IsPlayerCanDiscardDeckAsCost(tp,i)
end
function s.thfilter(c)
	return c:IsSetCard(ARCHE_AUTOMATYRANT) and c:IsLevelAbove(7) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,ARCHE_AUTOMATYRANT),tp,LOCATION_ONFIELD,0,1,nil) and e:IsCostChecked() and Duel.IsPlayerCanDiscardDeckAsCost(tp,1)
		and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0
	local b2=Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	if chk==0 then
		return b1 or b2
	end
	local opt=aux.Option(tp,id,1,b1,b2)
	local param=opt
	if opt==0 then
		e:SetCategory(CATEGORY_DESTROY|CATEGORY_DAMAGE)
		local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		if e:IsCostChecked() then
			local ct=#g
			local n=Duel.AnnounceNumberMinMax(tp,1,ct,s.validnum)
			Duel.DiscardDeck(tp,n,REASON_COST)
			local ogct=Duel.GetGroupOperatedByThisCost(e):FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
			param=param|(ogct<<16)
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ogct,1-tp,LOCATION_ONFIELD)
			if ogct>=3 then
				Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ogct*500)
			end
		end
	elseif opt==1 then
		e:SetCategory(CATEGORIES_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	end
	Duel.SetTargetParam(param)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local param=Duel.GetTargetParam()
	local opt=param&0x1
	if opt==0 then
		local ct=param>>16
		local g=Duel.Select(HINTMSG_DESTROY,false,tp,nil,tp,0,LOCATION_ONFIELD,ct,ct,nil)
		if #g>0 then
			Duel.HintSelection(g)
			if Duel.Destroy(g,REASON_EFFECT)>=3 then
				local og=Duel.GetGroupOperatedByThisEffect(e)
				if #og>=3 then
					Duel.BreakEffect()
					Duel.Damage(1-tp,#og*500,REASON_EFFECT)
				end
			end
		end
	elseif opt==1 then
		local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.Search(g)
		end
	end
end

--E2
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_AUTOMATYRANT)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and ((c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_HAND|LOCATION_DECK)) or (c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)))
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(Card.IsAbleToDeck,tp,LOCATION_GB,0,nil)
	if chk==0 then
		return #g>0 and Duel.IsPlayerCanDiscardDeck(tp,10)
	end
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,10)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return end
	local g=Duel.Group(Card.IsAbleToDeck,tp,LOCATION_GB,0,nil)
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 then
		Duel.DiscardDeck(tp,10,REASON_EFFECT)
	end
end