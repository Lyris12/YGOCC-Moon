--[[
Voidictator Rune - Ultimate Gating Art
Runa dei Vuotodespoti - Arte dei Portali Finale
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[ If you control a "Voidictator Demon" monster: Activate 1 of the following effects, depending on the "Voidictator Demon" monsters you control. Your opponent cannot activate cards or effects in response to this card's activation if you control "Voidictator Demon - The Gate Keeper".
	● Any "Voidictator Demon" monster: Target up to 3 of your banished "Voidictator Servant" monsters; Special Summon those monsters in face-up Defense Position, but they cannot activate their effects this turn.
	● "Voidictator Demon - The Gate Keeper": Special Summon 1 "Voidictator Deity" or "Voidictator Demon" monster from your Extra Deck, instead. If you Special Summon "Voidictator Demon - The Unending Flame" with this effect, attach the top 3 cards of your Deck to it as material.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(aux.LocationGroupCond(s.cfilter,LOCATION_MZONE,0,1),nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this card is banished because of a "Voidictator" card you own: You can Tribute 2 "Voidictator Servant" monsters you control;
	return as many monsters your opponent controls as possible to the hand.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(3)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:HOPT()
	e2:SetFunctions(s.setcon,s.setcost,s.settg,s.setop)
	c:RegisterEffect(e2)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end

--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_VOIDICTATOR_DEMON)
end
function s.cfilter2(c)
	return c:IsFaceup() and c:IsCode(CARD_VOIDICTATOR_DEMON_THE_GATEKEEPER)
end
function s.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_VOIDICTATOR_SERVANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.spfilter2(c,e,tp)
	return c:IsSetCard(ARCHE_VOIDICTATOR_DEITY,ARCHE_VOIDICTATOR_DEMON) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter1(chkc,e,tp) end
	local b1=Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.GetMZoneCount(tp)>0 and Duel.IsExists(true,s.spfilter1,tp,LOCATION_REMOVED,0,1,nil,e,tp)
	local b2=Duel.IsExists(false,s.cfilter2,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExists(false,s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil)
	if chk==0 then
		return b1 or b2
	end
	local opt=aux.Option(tp,id,1,b1,b2)
	if opt==0 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		local ft=Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and 1 or math.min(3,Duel.GetMZoneCount(tp))
		local g=Duel.Select(HINTMSG_SPSUMMON,true,tp,s.spfilter1,tp,LOCATION_REMOVED,0,1,ft,nil,e,tp)
		Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
	elseif opt==1 then
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
	Duel.SetTargetParam(opt)
	if Duel.IsExists(false,s.cfilter2,tp,LOCATION_ONFIELD,0,1,nil) then
		Duel.SetChainLimit(s.chlimit)
	end
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetTargetParam()
	if not opt then return end
	if opt==0 then
		local g=Duel.GetTargetCards()
		if #g<=0 or (Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and #g>1) then return end
		local ft=Duel.GetMZoneCount(tp)
		if #g>ft then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			g=g:Select(tp,ft,ft,nil)
		end
		local c=e:GetHandler()
		for tc in aux.Next(g) do
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(STRING_CANNOT_TRIGGER)
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_TRIGGER)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
				tc:RegisterEffect(e1,true)
			end
		end
		Duel.SpecialSummonComplete()
		
	elseif opt==1 then
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
			local sc=Duel.GetOperatedGroup():GetFirst()
			if sc:IsFaceup() and sc:IsCode(CARD_VOIDICTATOR_DEMON_THE_GATEKEEPER) and sc:IsType(TYPE_XYZ) then
				local dg=Duel.GetDecktopGroup(tp,3):Filter(Card.IsCanOverlay,nil,tp)
				if #dg==3 then
					Duel.Attach(dg,sc)
				end
			end
		end
	end
end

--E2
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.costfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_VOIDICTATOR_SERVANT)
end
function s.fselect(g,tp)
	return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,g)
		and Duel.CheckReleaseGroup(tp,aux.IsInGroup,#g,nil,g)
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetReleaseGroup(tp):Filter(s.costfilter,nil)
	if chk==0 then return g:CheckSubGroup(s.fselect,2,2,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local rg=g:SelectSubGroup(tp,s.fselect,false,2,2,tp)
	aux.UseExtraReleaseCount(rg,tp)
	Duel.Release(rg,REASON_COST)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(Card.IsAbleToHand,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return e:IsCostChecked() or #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,1-tp,LOCATION_MZONE)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(Card.IsAbleToHand,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end