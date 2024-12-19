--[[
ZERO Reincarnation
Reincarnazione ZERO
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--[[When this card is activated: You can target any number of monsters in your GY and/or banishment with 0 original ATK/DEF; Special Summon those targets, but they cannot be used as Xyz or Link
	Materials.]]
	local e1=c:Activation(true,true,nil,nil,s.target,s.activate,true)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	c:RegisterEffect(e1)
	--[[While you control 4 or more monsters with 0 ATK/DEF, your opponent cannot conduct their Battle Phase.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_BP)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(aux.LocationGroupCond(aux.FaceupFilter(Card.IsStats,0,0),LOCATION_MZONE,0,4))
	c:RegisterEffect(e2)
	--[[Once per turn, during your Standby Phase: Tribute 1 monster, or place this card on the top of your Deck.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,0)
	e3:SetCategory(CATEGORY_RELEASE|CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:OPT()
	e3:SetFunctions(aux.TurnPlayerCond(0),nil,s.mttg,s.mtop)
	c:RegisterEffect(e3)
end
--E1
function s.filter(c,e,tp)
	return c:IsFaceupEx() and c:IsMonster() and c:IsBaseStats(0,0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GB) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return true end
	local ft=Duel.GetMZoneCountForMultipleSummons(tp)
	if ft>0 then
		local g=Duel.Group(s.filter,tp,LOCATION_GB,0,nil,e,tp)
		if #g>0 and Duel.SelectYesNo(tp,STRING_ASK_SPSUMMON) then
			Duel.HintMessage(tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,math.min(ft,#g),nil)
			Duel.SetTargetCard(sg)
			Duel.SetCardOperationInfo(sg,CATEGORY_SPECIAL_SUMMON)
		end
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetMZoneCountForMultipleSummons(tp)
	if ft==0 then return end
	local g=Duel.GetTargetCards()
	if not g or #g==0 then return end
	g=g:Filter(s.filter,nil,e,tp)
	if #g>0 then
		if ft<#g then
			Duel.HintMessage(tp,HINTMSG_SPSUMMON)
			g=g:Select(tp,ft,ft,nil)
		end
		for tc in aux.Next(g) do
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				tc:CannotBeMaterial(TYPE_XYZ|TYPE_LINK,nil,true,c,range,nil,nil,true)
			end
		end
		Duel.SpecialSummonComplete()
	end
end

--E3
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.SetPossibleOperationInfo(0,CATEGORY_RELEASE,c,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		local b1=Duel.CheckReleaseGroupEx(tp,nil,1,REASON_EFFECT,false,c)
		local b2=c:IsAbleToDeck()
		if not b1 and not b2 then return end
		local opt=aux.Option(tp,nil,nil,{b1,STRING_RELEASE},{b2,STRING_SEND_TO_DECK})
		if opt==0 then
			local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_EFFECT,false,c)
			Duel.Release(g,REASON_EFFECT)
		elseif opt==1 then
			Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end