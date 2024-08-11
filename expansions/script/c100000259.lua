--[[
Azura, Godspark of the Bright Tide
Azura, Divinascintilla della Marea Luminosa
Card Author: Swag
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--1 Tuner + 1+ "Godspark" non-Tuner monsters
	aux.AddSynchroMixProcedure(c,s.tunerfilter,nil,nil,aux.NonTuner(Card.IsSetCard,ARCHE_GODSPARK),1,99)
	--You can only Special Summon "Azura, Godspark of the Bright Tide" once per turn.
	c:SetSPSummonOnce(id)
	--While face-up on the field, this card is also LIGHT-Attribute.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_ATTRIBUTE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e0)
	--[[If this card is Synchro Summoned: You can target 1 Level 5 "Godspark" Synchro Monster in your GY; Special Summon it at the start of the next turn.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.SynchroSummonedCond,nil,s.sptg,s.spop)
	c:RegisterEffect(e1)
	--[[If "Gorgeous Gift of Heaven - The Godspark" is in your GY (Quick Effect): You can banish 1 "Godspark" monster from your GY,
	then target 1 "Godspark" monster in your GY with a different Type and Attribute from the banished monster; Special Summon it, but you cannot activate this effect during the next turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,3)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(
		s.discon,
		aux.DummyCost,
		s.distg,
		s.disop
	)
	c:RegisterEffect(e2)
end
function s.tunerfilter(c,syncard)
	return c:IsTuner(syncard) or (c:IsType(TYPE_SYNCHRO) and c:IsSetCard(ARCHE_GODSPARK))
end

--E1
function s.spfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(ARCHE_GODSPARK) and c:IsLevel(5)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc) end
	if chk==0 then
		return Duel.IsExists(true,s.spfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	local g=Duel.Select(HINTMSG_SPSUMMON,true,tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local ct=Duel.GetTurnCount()
		local rct=Duel.GetNextPhaseCount(PHASE_DRAW)
		local eid=e:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DRAW,EFFECT_FLAG_CLIENT_HINT,rct,eid,aux.Stringid(id,1))
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(id,2)
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_TURN_END)
		e1:OPT()
		e1:SetOperation(
			function(_e,_tp)
				local e2=Effect.CreateEffect(c)
				e2:SetDescription(id,0)
				e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
				e2:SetCode(EVENT_ADJUST)
				e2:SetLabel(ct,eid)
				e2:SetLabelObject(tc)
				e2:SetCondition(s.spcon1)
				e2:SetOperation(s.spop1)
				e2:SetReset(RESET_PHASE|PHASE_DRAW,rct)
				Duel.RegisterEffect(e2,_tp)
				_e:Reset()
			end
		)
		e1:SetReset(RESET_PHASE|PHASE_DRAW,rct)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local ct,eid=e:GetLabel()
	local tc=e:GetLabelObject()
	if not tc or not tc:HasFlagEffectLabel(id,eid) then
		e:Reset()
		return false
	end
	return Duel.GetTurnCount()~=ct
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local _,eid=e:GetLabel()
	local tc=e:GetLabelObject()
	if tc and tc:HasFlagEffectLabel(id,eid) and Duel.GetMZoneCount(tp)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	e:Reset()
end

--E2
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,CARD_GORGEOUS_GIFT_OF_HEAVEN_THE_GODSPARK),tp,LOCATION_GRAVE,0,1,nil)
end
function s.cfilter(c,e,tp)
	return c:IsMonster() and c:IsSetCard(ARCHE_GODSPARK) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExists(true,s.disfilter,tp,LOCATION_GRAVE,0,1,c,e,tp,c:GetRace(),c:GetAttribute())
end
function s.disfilter(c,e,tp,rc,attr)
	return c:IsSetCard(ARCHE_GODSPARK) and not c:IsRace(rc) and not c:IsAttribute(attr) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local rc,attr=e:GetLabel()
		return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.disfilter(chkc,e,tp,rc,attr)
	end
	if chk==0 then
		return not Duel.PlayerHasFlagEffect(tp,id+100) and e:IsCostChecked() and Duel.IsExists(false,s.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) 
	end
	local tc=Duel.Select(HINTMSG_REMOVE,false,tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	local rc,attr=tc:GetRace(),tc:GetAttribute()
	e:SetLabel(rc,attr)
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	local g=Duel.Select(HINTMSG_SPSUMMON,true,tp,s.disfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,rc,attr)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,EFFECT_FLAG_CLIENT_HINT,2,0,aux.Stringid(id,4))
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end