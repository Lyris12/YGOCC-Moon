--Aeonstrider Courier
--Corriere Marciaeoni
--Scripted by: XGlitchy30

local s,id,o=GetID()
xpcall(function() require("expansions/script/glitchylib_helper") end,function() require("script/glitchylib_helper") end)
xpcall(function() require("expansions/script/glitchylib_aeonstride") end,function() require("script/glitchylib_aeonstride") end)
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c,false)
	aux.SpawnGlitchyHelper(GLITCHY_HELPER_TURN_COUNT_FLAG)
	aux.RaiseAeonstrideEndOfTurnEvent(c)
	c:Activation()
	--[[This card's Pendulum Scale is equal to the current Turn Count.]]
	local p0=Effect.CreateEffect(c)
	p0:SetType(EFFECT_TYPE_SINGLE)
	p0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SINGLE_RANGE)
	p0:SetCode(EFFECT_CHANGE_LSCALE)
	p0:SetRange(LOCATION_PZONE)
	p0:SetValue(s.scale)
	c:RegisterEffect(p0)
	local p00=p0:Clone()
	p00:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(p00)
	--[[If the Turn Count moves forward (except during the Damage Step): You can Special Summon this card, and if you do, you can place in your Pendulum Zone, 1 of your "Aeonstride" Pendulum Monsters that is banished, in your Deck, or in your GY.]]
	local PZChk=aux.AddThisCardInPZoneAlreadyCheck(c)
	local p1=Effect.CreateEffect(c)
	p1:Desc(0)
	p1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	p1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	p1:SetProperty(EFFECT_FLAG_DELAY)
	p1:SetCode(EVENT_TURN_COUNT_MOVED)
	p1:SetRange(LOCATION_PZONE)
	p1:HOPT()
	p1:SetLabelObject(p1)
	p1:SetFunctions(s.exccon,nil,s.exctg,s.excop)
	c:RegisterEffect(p1)
	aux.RegisterTurnCountTriggerEffectFlag(c,p1)
	--[[If this card is Normal or Special Summoned: You can Special Summon 1 "Aeonstride" monster from your Deck, except "Aeonstrider Courier", then add this card to your Extra Deck, face-up.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetCategory(CATEGORY_TOEXTRA|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.optg,s.opop)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--[[If this card is added to your Extra Deck, face-up: You can add to your hand, 1 "Aeonstride" card from your Deck,
	or 1 "Aeonstride Pendulum Monster from your face-up Extra Deck, then move the Turn Count forwards by 1 turn.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_DECK)
	e2:HOPT()
	e2:SetFunctions(s.thcon,nil,s.thtg,s.thop)
	c:RegisterEffect(e2)
end
--P0
function s.scale(e,c)
	return Duel.GetTurnCount(nil,true)
end

--F1
function s.excfilter(c,tp)
	return c:IsMonster(TYPE_PENDULUM) and c:IsSetCard(ARCHE_AEONSTRIDE) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
--P1
function s.exccon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	if not (se==nil or not re or re~=se) then return false end
	if aux.TurnCountMovedDueToTurnEnd then
		return r&REASON_RULE==0
	else
		return ev>0
	end
end
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetMZoneCount(tp)>0 and c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.CheckPendulumZones(tp)
		and Duel.IsExists(false,aux.Necro(s.excfilter),tp,LOCATION_DECK|LOCATION_GB,0,1,nil,tp) and c:AskPlayer(tp,STRING_ASK_PLACE_IN_PZONE) then
		local sg=Duel.Select(HINTMSG_TOZONE,false,tp,aux.Necro(s.excfilter),tp,LOCATION_DECK|LOCATION_GB,0,1,1,nil,tp)
		if #sg>0 then
			Duel.MoveToField(sg:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end

--FE1
function s.opfilter(c,e,tp)
	return c:IsSetCard(ARCHE_AEONSTRIDE) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--E1
function s.optg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.opfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and c:IsAbleToExtra()
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetCardOperationInfo(c,CATEGORY_TOEXTRA)
end
function s.opop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local c=e:GetHandler()
	local sg=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.opfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsRelateToChain() and c:IsAbleToExtra() then
		Duel.BreakEffect()
		Duel.SendtoExtraP(c,nil,REASON_EFFECT)
	end
end

--FE2
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_AEONSTRIDE) and (not c:IsInExtra() or c:IsMonster(TYPE_PENDULUM)) and c:IsAbleToHand()
end
--E2
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsInExtra(POS_FACEUP)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil) and Duel.IsPlayerCanMoveTurnCount(1,e,tp,REASON_EFFECT)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		local ct,ht=Duel.Search(g,tp)
		if ct>0 and ht>0 and Duel.IsPlayerCanMoveTurnCount(1,e,tp,REASON_EFFECT) then
			Duel.BreakEffect()
			Duel.MoveTurnCountCustom(1,e,tp,REASON_EFFECT)
		end
	end
end