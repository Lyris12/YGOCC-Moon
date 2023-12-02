--[[
Quadratic Curse
Maledizione Quadratica
Card Author: Xarc
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[This card is used to Ritual Summon "Diabolical Quarphex LV4". You must also Tribute monsters from your hand or field whose total Levels equal 4 or more.]]
	aux.AddRitualProcGreaterCode(c,CARD_DIABOLICAL_QUARPHEX_LV4)
	--[[If this card is in your GY: You can target 1 "Quarphex" monster in your GY; add either this card or that card to your hand, and if you do,
	place the other on the bottom of the Deck, then you can draw 1 card.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_TODECK|CATEGORY_DRAW|CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(nil,nil,s.target,s.operation)
	c:RegisterEffect(e2)
end
--E2
function s.filter(c,h)
	return c:IsMonster() and c:IsSetCard(ARCHE_QUARPHEX)
		and ((h:IsAbleToHand() and c:IsAbleToDeck()) or (c:IsAbleToHand() and h:IsAbleToDeck()))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc~=c and s.filter(chkc) end
	if chk==0 then
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,c,c)
	end
	Duel.HintMessage(tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,c,c)
	local infog=Group.FromCards(c,g:GetFirst())
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,infog,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,infog,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local g=Group.FromCards(c,tc):Filter(Card.IsRelateToChain,nil)
	Duel.HintMessage(tp,HINTMSG_RTOHAND)
	local thg=g:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
	if #thg>0 and Duel.SearchAndCheck(thg,tp) then
		Duel.HintMessage(tp,HINTMSG_TODECK)
		local tdg=g:FilterSelect(tp,Card.IsAbleToDeck,1,1,thg)
		if #tdg>0 and Duel.ShuffleIntoDeck(tdg,nil,nil,SEQ_DECKBOTTOM)>0 and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,STRING_ASK_DRAW) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end