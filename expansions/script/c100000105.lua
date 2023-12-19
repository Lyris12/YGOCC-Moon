--Aeonstrider Conductor
--Direttore Marciaeoni
--Scripted by: XGlitchy30

local s,id,o=GetID()
Duel.LoadScript("glitchylib_helper.lua")
Duel.LoadScript("glitchylib_aeonstride.lua")
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c,false)
	aux.SpawnGlitchyHelper(GLITCHY_HELPER_TURN_COUNT_FLAG)
	aux.RaiseAeonstrideEndOfTurnEvent(c)
	c:Activation()
	--[[When this card is placed in your Pendulum Zone, place Chronus Counters on it equal to the current Turn Count +1.]]
	local p0=Effect.CreateEffect(c)
	p0:Desc(0)
	p0:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	p0:SetCode(EVENT_MOVE)
	p0:SetFunctions(s.ctcon,nil,nil,s.ctop)
	c:RegisterEffect(p0)
	--[[Once per turn: You can remove any number of Chronus Counters from your field, then target 1 "Aeonstride" monster you control;
	increase or decrease its Level by the number of counters removed, then you can place 1 Chronus Counter on it.]]
	local p1=Effect.CreateEffect(c)
	p1:Desc(1)
	p1:SetCategory(CATEGORY_COUNTER)
	p1:SetType(EFFECT_TYPE_IGNITION)
	p1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	p1:SetRange(LOCATION_PZONE)
	p1:OPT()
	p1:SetFunctions(nil,aux.DummyCost,s.exctg,s.excop)
	c:RegisterEffect(p1)
	--[[If you control an "Aeonstride" monster, you can Special Summon this card (from your hand).]]
	c:SSProc(2,false,LOCATION_HAND,false,s.spsumcond)
	--[[If this card is added to the Extra Deck, face-up: You can add up to 2 other "Aeonstride" Pendulum Monsters that are face-up in your Extra Deck to your hand,
	whose total Levels are equal to or less than the current Turn Count +3.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(3)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_DECK)
	e1:HOPT()
	e1:SetFunctions(s.thcon,nil,s.thtg,s.thop)
	c:RegisterEffect(e1)
	--[[(Quick Effect): You can add this card from your hand or field to your Extra Deck, face-up; banish 2 or more "Aeonstride" monsters from your field or face-up Extra Deck,
	then Special Summon 1 Synchro Monster from your Extra Deck whose Level equals the total Level of those banished monsters. (This is treated as a Synchro Summon).]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(4)
	e2:SetCategory(CATEGORY_REMOVE|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(nil,s.syncost,s.syntg,s.synop)
	c:RegisterEffect(e2)
end
--P0
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsPreviousLocation(LOCATION_PZONE) and c:IsLocation(LOCATION_PZONE)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetTurnCount(nil,true)+1
	if ct>0 and c:IsCanAddCounter(COUNTER_CHRONUS,ct) then
		c:AddCounter(COUNTER_CHRONUS,ct)
	end
end

--F1
function s.excfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(ARCHE_AEONSTRIDE) and c:HasLevel()
end
--P1
function s.ncheck(tp)
	return	function(i)
				return Duel.IsCanRemoveCounter(tp,1,0,COUNTER_CHRONUS,i,REASON_COST)
			end
end
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then
		return e:IsCostChecked() and Duel.IsCanRemoveCounter(tp,1,0,COUNTER_CHRONUS,1,REASON_COST) and Duel.IsExists(true,s.excfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	local g=Duel.Select(HINTMSG_LVRANK,true,tp,s.excfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local max=Duel.GetCounter(tp,1,0,COUNTER_CHRONUS)
	Duel.HintMessage(tp,HINTMSG_NUMBER)
	local ct=Duel.AnnounceNumberMinMax(tp,1,max,s.ncheck)
	if ct>0 then
		Duel.RemoveCounter(tp,1,0,COUNTER_CHRONUS,ct,REASON_COST)
		e:SetLabel(ct)
	else
		e:SetLabel(0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_COUNTER,g,#g,0,0,COUNTER_CHRONUS,ct)
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local ct=e:GetLabel()
	if ct>0 and tc and tc:IsRelateToChain() and tc:IsFaceup() then
		local opt=aux.Option(tp,false,false,{true,STRING_INCREASE},{tc:GetLevel()>ct,STRING_DECREASE})
		if not opt then return end
		if opt==1 then ct=-ct end
		local c=e:GetHandler()
		local de,diff=tc:UpdateLevel(ct,true,c)
		if diff~=0 and not tc:IsImmuneToEffect(de) and tc:IsRelateToChain() and tc:IsCanAddCounter(COUNTER_CHRONUS,1) and c:AskPlayer(tp,STRING_ASK_PLACE_COUNTER) then
			Duel.BreakEffect()
			tc:AddCounter(COUNTER_CHRONUS,1)
		end
	end
end

--E0
function s.spsumcond(e,c,tp)
	return Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,ARCHE_AEONSTRIDE),tp,LOCATION_MZONE,0,1,nil)
end

--FE1
function s.thfilter(c,lv)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_AEONSTRIDE) and c:IsMonster(TYPE_PENDULUM) and c:IsLevelBelow(lv) and c:IsAbleToHand()
end
function s.lvchk(ct)
	return	function(g)
				return g:GetSum(Card.GetLevel)<=ct
			end
end
--E1
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsInExtra(POS_FACEUP)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=Duel.GetTurnCount(nil,true)+3
		if ct<=0 then return false end
		local g=Duel.Group(s.thfilter,tp,LOCATION_EXTRA,0,e:GetHandler(),ct)
		if #g<=0 then return false end
		aux.GCheckAdditional=s.lvchk(ct)
		local res=g:CheckSubGroup(aux.TRUE,1,2)
		aux.GCheckAdditional=nil
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetTurnCount(nil,true)+3
	if ct<=0 then return false end
	local g=Duel.Group(s.thfilter,tp,LOCATION_EXTRA,0,aux.ExceptThis(e:GetHandler()),ct)
	if #g>0 then
		Duel.HintMessage(tp,HINTMSG_ATOHAND)
		aux.GCheckAdditional=s.lvchk(ct)
		local sg=g:SelectSubGroup(tp,aux.TRUE,false,1,2)
		aux.GCheckAdditional=nil
		if #sg>0 then
			Duel.Search(sg,tp)
		end
	end
end

--FE2
function s.synfilter(c,e,tp,exc)
	if not c:IsType(TYPE_SYNCHRO) or not c:HasLevel() or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) then return false end
	local lv=c:GetLevel()
	local g=Duel.Group(s.rmfilter,tp,LOCATION_MZONE|LOCATION_EXTRA,0,exc,lv)
	aux.GCheckAdditional=s.lvchk(lv)
	local res=g:CheckSubGroup(s.fgoal,2,2,c,tp,lv,exc)
	aux.GCheckAdditional=nil
	return res
end
function s.rmfilter(c,lv)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(ARCHE_AEONSTRIDE) and c:IsLevelBelow(lv) and c:IsAbleToRemove()
end
function s.fgoal(g,c,tp,lv,exc)
	local exg=g:Clone()
	if exc then exg:AddCard(exc) end
	return g:GetClassCount(Card.GetCode)==#g and Duel.GetLocationCountFromEx(tp,tp,exg,c)>0 and g:GetSum(Card.GetLevel)==lv
end
--E2
function s.syncost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if not c:IsAbleToExtraFaceupAsCost(tp,tp) or not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return false end
		return Duel.IsExists(false,s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
	end
	Duel.SendtoExtraP(c,nil,REASON_COST)
end
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return e:IsCostChecked() or (aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) and Duel.IsExists(false,s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil))
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_MZONE|LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	local g1=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g1:GetFirst()
	if tc then
		local lv=tc:GetLevel()
		local mg=Duel.Group(s.rmfilter,tp,LOCATION_MZONE|LOCATION_EXTRA,0,nil,lv)
		if #mg<2 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		aux.GCheckAdditional=s.lvchk(lv)
		local g2=mg:SelectSubGroup(tp,s.fgoal,false,2,2,tc,tp,lv,nil)
		aux.GCheckAdditional=nil
		if #g2>0 and Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)>0 then
			tc:SetMaterial(nil)
			Duel.BreakEffect()
			if Duel.SpecialSummonStep(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP) then
				tc:CompleteProcedure()
			end
			Duel.SpecialSummonComplete()
		end
	end
end