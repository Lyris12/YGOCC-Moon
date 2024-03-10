--created by Walrus, coded by XGlitchy30
--Voidictator Rune - Gating Art
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:HOPT()
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end
function s.scfilter(c)
	return c:IsSetCard(ARCHE_VOIDICTATOR) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_VOIDICTATOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_VOIDICTATOR) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=not Duel.PlayerHasFlagEffectLabel(tp,id,1) and Duel.IsExists(false,s.scfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	local b2=not Duel.PlayerHasFlagEffectLabel(tp,id,2) and Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE|LOCATION_HAND,0,1,nil,e,tp)
	local b3=not Duel.PlayerHasFlagEffectLabel(tp,id,3) and Duel.IsExists(false,s.thfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsPlayerCanDraw(tp,1)
	if chk==0 then
		return b1 or b2 or b3
	end
	e:SetCategory(0)
	local opt=aux.Option(tp,id,2,b1,b2,b3)
	if opt==0 then
		e:SetCategory(CATEGORIES_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	elseif opt==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED|LOCATION_GRAVE|LOCATION_HAND)
	elseif opt==2 then
		e:SetCategory(CATEGORY_TOHAND|CATEGORY_DRAW)
		local g=Duel.Group(s.thfilter,tp,LOCATION_MZONE,0,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_MZONE)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
	Duel.SetTargetParam(opt)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1,opt+1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetTargetParam()
	if opt==0 then
		local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.scfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.Search(g,tp)
		end
	elseif opt==1 then
		if Duel.GetMZoneCount(tp)<=0 then return end
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_REMOVED|LOCATION_GRAVE|LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif opt==2 then
		local tc=Duel.Select(HINTMSG_RTOHAND,false,tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc and Duel.SendtoHand(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
			if Duel.IsPlayerCanDraw(tp,1) then
				Duel.BreakEffect()
			end
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
function s.thfilter2(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_VOIDICTATOR) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.thfilter2,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter2,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end
