--Aeonstrider Scout
--Esploratore Marciaeoni
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
	--[[If the Turn Count moves forward (except during the Damage Step): You can take 1 "Aeonstride" Spell/Trap from your Deck, and either Set it to your field or banish it,
	and if you do, you can Special Summon this card.]]
	local PZChk=aux.AddThisCardInPZoneAlreadyCheck(c)
	local p1=Effect.CreateEffect(c)
	p1:Desc(0)
	p1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_REMOVE)
	p1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	p1:SetProperty(EFFECT_FLAG_DELAY)
	p1:SetCode(EVENT_TURN_COUNT_MOVED)
	p1:SetRange(LOCATION_PZONE)
	p1:HOPT()
	p1:SetLabelObject(p1)
	p1:SetFunctions(s.exccon,nil,s.exctg,s.excop)
	c:RegisterEffect(p1)
	aux.RegisterTurnCountTriggerEffectFlag(c,p1)
	--[[If this card is Normal or Special Summoned: You can take 1 "Aeonstride" Pendulum Monster from your Deck, and either place it in your Pendulum Zone, or add it to your Extra Deck, face-up.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.optg,s.opop)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--[[(Quick Effect): You can add this card you control to your Extra Deck, face-up;
	Special Summon 1 "Aeonstride" monster from your hand, GY, or face-up Extra Deck, except "Aeonstride Scout", and if you do, move the Turn Count forwards by 1 turn.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(3)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(nil,s.spcost,s.sptg,s.spop)
	c:RegisterEffect(e2)
end
--P0
function s.scale(e,c)
	return Duel.GetTurnCount(nil,true)
end

--F1
function s.excfilter(c)
	return c:IsST() and c:IsSetCard(ARCHE_AEONSTRIDE) and (c:IsSSetable() or c:IsAbleToRemove())
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
	if chk==0 then
		return Duel.IsExists(false,s.excfilter,tp,LOCATION_DECK,0,1,nil)
	end
	local c=e:GetHandler()
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,c:GetControler(),c:GetLocation())
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.Select(HINTMSG_OPERATECARD,false,tp,s.excfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #sg>0 then
		local tc=sg:GetFirst()
		local check=false
		local opt=aux.Option(tp,false,false,{tc:IsSSetable(),STRING_SET},{tc:IsAbleToRemove(),STRING_BANISH})
		if opt==0 then
			if Duel.SSet(tp,tc)>0 and aux.PLChk(tc,tp,LOCATION_SZONE,POS_FACEDOWN) then
				check=true
			end
		elseif opt==1 then
			if Duel.Banish(tc,nil,REASON_EFFECT|REASON_EXCAVATE)>0 then
				check=true
			end
		end
		local c=e:GetHandler()
		if check and c:IsRelateToChain() and Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:AskPlayer(tp,1) then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

--FE1
function s.opfilter(c,tp,pzchk)
	return c:IsMonster(TYPE_PENDULUM) and c:IsSetCard(ARCHE_AEONSTRIDE) and not c:IsForbidden() and ((pzchk and c:CheckUniqueOnField(tp)) or c:IsAbleToExtra())
end
--E1
function s.optg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.opfilter,tp,LOCATION_DECK,0,1,nil,tp,Duel.CheckPendulumZones(tp))
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
function s.opop(e,tp,eg,ep,ev,re,r,rp)
	local pzchk=Duel.CheckPendulumZones(tp)
	local sg=Duel.Select(HINTMSG_OPERATECARD,false,tp,s.opfilter,tp,LOCATION_DECK,0,1,1,nil,tp,pzchk)
	if #sg>0 then
		local tc=sg:GetFirst()
		local b1=(pzchk and tc:CheckUniqueOnField(tp))
		local opt=aux.Option(tp,false,false,{b1,STRING_PLACE_IN_PZONE},{tc:IsAbleToExtra(),STRING_SEND_TO_EXTRA})
		if opt==0 then
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		elseif opt==1 then
			Duel.SendtoExtraP(tc,nil,REASON_EFFECT)
		end
	end
end

--FE2
function s.spfilter(c,e,tp,exc)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_AEONSTRIDE) and not c:IsCode(id) and Duel.GetMZoneCountFromLocation(tp,tp,exc,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--E2
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraFaceupAsCost(tp,tp) and Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil,e,tp,c) end
	Duel.SendtoExtraP(c,nil,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return (e:IsCostChecked() or Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil,e,tp,nil)) and Duel.IsPlayerCanMoveTurnCount(1,e,tp,REASON_EFFECT)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.MoveTurnCountCustom(1,e,tp,REASON_EFFECT)
	end
end