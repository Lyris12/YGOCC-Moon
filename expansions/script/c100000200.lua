--[[
Realza, Seeker of the Silent Star
Realza, Cercatrice della Stella Silente
Card Author: Zerry
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_WARRIOR),2,2,s.lcheck)
	--[[This card can be treated as a Level 4 monster for the Xyz Summon of a "Silent Star" Xyz Monster.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.xyzlv)
	c:RegisterEffect(e1)
	--[[During your Main Phase: You can send 4 "Star Regalia" cards with different names from your Deck to your GY; Special Summon 1 "Silent Star" monster from your Deck or GY.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(nil,s.spcost,s.sptg,s.spop)
	c:RegisterEffect(e2)
	--[[If this card is detached from a "Silent Star" Xyz Monster: You can target up to 3 "Silent Star" and/or "Star Regalia" cards in your GY; shuffle them into the Deck.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_MOVE)
	e3:HOPT()
	e3:SetFunctions(s.tdcon,nil,s.tdtg,s.tdop)
	c:RegisterEffect(e3)
end
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,ARCHE_SILENT_STAR)
end

--E1
function s.xyzlv(e,c,xyzc)
	if xyzc:IsSetCard(ARCHE_SILENT_STAR) then
		return 4
	else
		return 0
	end
end

--E2
function s.tgfilter(c)
	return c:IsSetCard(ARCHE_STAR_REGALIA) and c:IsAbleToGraveAsCost()
end
function s.gcheck(g,e,tp)
	return aux.dncheck(g) and Duel.IsExists(false,s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,g,e,tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_SILENT_STAR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then
		return #g>0 and g:CheckSubGroup(s.gcheck,4,4,e,tp)
	end
	Duel.HintMessage(tp,HINTMSG_TOGRAVE)
	local sg=g:SelectSubGroup(tp,s.gcheck,false,4,4,e,tp)
	if #sg>0 then
		Duel.SendtoGrave(sg,REASON_COST)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and (e:IsCostChecked() or Duel.IsExists(false,s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp))
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.spfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E3
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local xyzc=c:GetPreviousXyzHolder()
	return c:IsPreviousLocation(LOCATION_OVERLAY) and not c:IsLocation(LOCATION_DECK) and c:IsFaceupEx() and xyzc and xyzc:IsFaceup() and xyzc:IsSetCard(ARCHE_SILENT_STAR)
end
function s.tdfilter(c)
	return c:IsSetCard(ARCHE_SILENT_STAR,ARCHE_STAR_REGALIA) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end