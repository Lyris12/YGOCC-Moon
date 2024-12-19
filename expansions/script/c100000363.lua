--[[
Power Vacuum Formation
Formazione di Potere Vacuum
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_VACUOUS_VASSAL,CARD_POWER_VACUUM_ZONE,CARD_POWER_VACUUM_BLADE)
	--[[If you control "Power Vacuum Zone", and a monster with "Power Vacuum Blade" equipped to it: Target 1 "Power Vacuum Blade" you control; shuffle that card and the monster it is equipped to into
	the Deck, and if you do, the ATK/DEF of all monsters your opponent controls becomes 0 (until the end of the turn), and if they do so by this effect, gain LP equal to that combined total lost
	ATK/DEF (max. 7000).]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_ATKDEF|CATEGORY_TODECK|CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:HOPT()
	e1:SetFunctions(s.condition,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this card is in your GY while you control "Power Vacuum Zone": You can banish this card from your GY; send 1 "Vacuous Vassal" from your hand or Deck to the GY, and if you do, add 1 Level 5
	or 7 "Vacuous" monster from your Deck to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TOGRAVE|CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetFunctions(
		aux.LocationGroupCond(aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_ZONE),LOCATION_ONFIELD,0,1),
		aux.bfgcost,
		s.thtg,
		s.thop)
	c:RegisterEffect(e2)
end
--E1
function s.eqfilter(c)
	return c:GetEquipGroup():IsExists(aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_BLADE),1,nil)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return aux.dscon(e,tp,eg,ep,ev,re,r,rp) and Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_ZONE),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExists(false,s.eqfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.pvbfilter(c,e,tp)
	if not (c:IsFaceup() and c:IsCode(CARD_POWER_VACUUM_BLADE) and c:IsAbleToDeck()) then return false end
	local ec=c:GetEquipTarget()
	return ec and ec:IsAbleToDeck() and Duel.IsExists(false,Card.IsCanChangeStats,tp,0,LOCATION_MZONE,1,c,0,0,e,tp,REASON_EFFECT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.pvbfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExists(true,s.pvbfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	local g=Duel.Select(HINTMSG_TODECK,true,tp,s.pvbfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	g:AddCard(g:GetFirst():GetEquipTarget())
	local atkg=Duel.Group(Card.IsCanChangeStats,tp,0,LOCATION_MZONE,g,0,0,e,tp,REASON_EFFECT)
	local atk=math.min(atkg:GetSum(Card.GetTotalStats),7000)
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
	Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,atkg,#atkg,0,0,{0})
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,atk)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local ec=tc:GetEquipTarget()
		if ec and Duel.ShuffleIntoDeck(Group.FromCards(tc,ec))==2 then
			local val=0
			local atkg=Duel.Group(Card.IsCanChangeStats,tp,0,LOCATION_MZONE,g,0,0,e,tp,REASON_EFFECT)
			for ac in aux.Next(atkg) do
				local ea,ed,_,_,_,_,diffa,diffd=ac:ChangeATKDEF(0,0,RESET_PHASE|PHASE_END,{c,true})
				if not ac:IsImmuneToEffect(ea) and diffa<0 then
					val=val-diffa
				end
				if not ac:IsImmuneToEffect(ed) and diffd<0 then
					val=val-diffd
				end
			end
			if val>0 then
				Duel.Recover(tp,math.min(val,7000),REASON_EFFECT)
			end
		end
	end
end

--E2
function s.tgfilter(c,tp)
	return c:IsCode(CARD_VACUOUS_VASSAL) and c:IsAbleToGrave() and (not tp or Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,nil))
end
function s.thfilter(c)
	return c:IsSetCard(ARCHE_VACUOUS) and c:IsLevel(5,7) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.ForcedSelect(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,tp)
	if #g1>0 and Duel.SendtoGraveAndCheck(g1) then
		local g2=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g2>0 then
			Duel.Search(g2)
		end
	end
end