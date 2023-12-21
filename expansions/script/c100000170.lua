--[[
Skyburner Support Vessels
Navi di Supporto Cielobruciatore
Card Author: LeonDuvall
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	if not s.progressive_id then
		s.progressive_id=id
	else
		s.progressive_id=s.progressive_id+1
	end
	
	c:SetUniqueOnField(1,0,id)
	--When this card is activated: You can send 1 "Skyburner" card from your Deck to the GY.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[Once per turn: You can target 1 "Skyburner" card in your GY; add it to your hand, then, if you control another "Skyburner" card or if you control no monsters,
	you can Special Summon 1 WIND Machine monster from your hand, but return it to your hand during the End Phase.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:OPT()
	e2:SetFunctions(nil,nil,s.thtg,s.thop)
	c:RegisterEffect(e2)
	--[[If a card(s) your opponent controls is destroyed, even during the Damage Step: You can Tribute this card, then declare 3 or 5;
	shuffle into the Deck that many of your "Skyburner" cards that are banished and/or in your GY, then, if you declared 5, you can shuffle that destroyed card(s) in your opponent's possession into the Deck.]]
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id,EVENT_DESTROYED,s.simfilter,id,LOCATION_SZONE,nil,LOCATION_SZONE,nil,id+100)
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_CUSTOM+s.progressive_id)
	e3:SetFunctions(nil,aux.TributeSelfCost,s.tdtg,s.tdop)
	c:RegisterEffect(e3)
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgfilter(c)
	return c:IsSetCard(ARCHE_SKYBURNER) and c:IsAbleToGrave()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if #g==0 or not Duel.SelectYesNo(tp,STRING_ASK_SEND_TO_GY) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=g:Select(tp,1,1,nil)
	if #tg>0 then
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end

--E2
function s.thfilter(c)
	return c:IsSetCard(ARCHE_SKYBURNER) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return c:IsAttributeRace(ATTRIBUTE_WIND,RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.SearchAndCheck(tc,tp)
		and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,ARCHE_SKYBURNER),tp,LOCATION_ONFIELD,0,1,aux.ExceptThis(c)))
		and Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.SelectYesNo(tp,STRING_ASK_SPSUMMON) then
		Duel.ShuffleHand(tp)
		local tc=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(id+200,RESET_EVENT|RESETS_STANDARD,0,1,fid)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EVENT_PHASE|PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(tc)
			e1:SetCondition(s.thcon2)
			e1:SetOperation(s.thop2)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local tc=e:GetLabelObject()
	if not tc or not tc:HasFlagEffectLabel(id+200,fid) then
		e:Reset()
		return false
	else
		return true
	end
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end

--E3
function s.simfilter(c,_,tp)
	return c:IsPreviousControler(1-tp)
end
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_SKYBURNER) and c:IsAbleToDeck()
end
function s.ofilter(c,tp)
	return c:IsAbleToDeck() and c:IsControler(1-tp)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.Group(s.tdfilter,tp,LOCATION_GB,0,nil)
	if chk==0 then return #tg>=3 end
	e:SetCategory(CATEGORY_TODECK)
	if #eg>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		eg=eg:SelectSubGroup(tp,aux.SimultaneousEventGroupCheck,false,1,#eg,id+100,eg)
		Duel.HintSelection(eg)
	end
	local avtab={}
	if #tg>=3 then
		table.insert(avtab,3)
	end
	if #tg>=5 then
		table.insert(avtab,5)
	end
	local n=Duel.AnnounceNumber(tp,table.unpack(avtab))
	Duel.SetTargetParam(n)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,n,0,0)
	if n==5 then
		Duel.SetTargetCard(eg)
		if eg:IsExists(Card.IsInGY,1,nil) then
			e:SetCategory(CATEGORY_TODECK|CATEGORY_GRAVE_ACTION)
		end
		Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,eg,#eg,0,0)
	end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local n=Duel.GetTargetParam()
	local tg=Duel.Select(HINTMSG_TODECK,false,tp,aux.Necro(s.tdfilter),tp,LOCATION_GB,0,n,n,nil)
	if #tg>0 then
		Duel.HintSelection(tg)
		if Duel.ShuffleIntoDeck(tg)>0 and n==5 then
			local g=Duel.GetTargetCards():Filter(s.ofilter,nil,tp)
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				Duel.BreakEffect()
				Duel.HintSelection(g)
				Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end