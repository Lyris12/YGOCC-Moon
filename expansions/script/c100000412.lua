--[[
Unknown HERO Timepiercer
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.RegisterCustomArchetype(id,CUSTOM_ARCHE_UNKNOWN_HERO)
	c:EnableReviveLimit()
	--fusion material
	aux.AddFusionProcCode3(c,100000409,100000410,100000411,true,true)
	local cf=aux.AddContactFusionProcedure(c,Card.IsAbleToExtraAsCost,LOCATION_ONFIELD,0,aux.tdcfop(c))
	cf:SetDescription(id,5)
	cf:SetValue(SUMMON_VALUE_SELF)
	--Must be either Fusion Summoned...
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--...or Special Summoned (from your Extra Deck) by returning the above cards you control to the Extra Deck (in which case you do not use "Polymerization"). If Special Summoned this way, return it to the Extra Deck during the 2nd Standby Phase after the turn it was Special Summoned.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.retop)
	c:RegisterEffect(e1)
	--If this card is Special Summoned: Shuffle as many cards from your GY and banishment into the Deck as possible, and if you do, this card gains 800 ATK for each card shuffled into the Deck this way.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(nil,nil,s.tdtg2,s.tdop2)
	c:RegisterEffect(e2)
	--During the Main Phase (Quick Effect): You can reveal 1 "HERO" monster from your Extra Deck, except "Unknown HERO Timepiercer"; for the rest of this turn, this card's name becomes that revealed monster's name, also replace this effect with that revealed monster's effects.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,3)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetHintTiming(TIMING_MAIN_END)
	e3:SetFunctions(aux.MainPhaseCond(),aux.DummyCost,s.reptg,s.repop)
	c:RegisterEffect(e3)
	--Your opponent takes no battle damage from attacks involving this card unless it was Fusion Summoned using "Greater Polymerization".
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e4:SetCondition(s.bdcon)
	c:RegisterEffect(e4)
end

--E0
function s.splimit(e,se,sp,st)
	return st&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION
end

--E1
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsSummonType(SUMMON_VALUE_SELF) then
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,1))
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetLabel(fid,Duel.GetTurnCount(),0)
		e1:SetCondition(s.tdcon)
		e1:SetOperation(s.tdop)
		e1:SetReset(RESET_PHASE|PHASE_STANDBY,Duel.GetCurrentPhase()<=PHASE_STANDBY and 3 or 2)
		Duel.RegisterEffect(e1,tp)
	elseif c:IsSummonType(SUMMON_TYPE_FUSION) and re and re:GetHandler():IsCode(7614732) then
		c:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))
	end
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	local fid,tct,ct=e:GetLabel()
	if not c:HasFlagEffectLabel(id,fid) then
		e:Reset()
		return false
	end
	return Duel.GetTurnCount()~=tct
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	local fid,tct,ct=e:GetLabel()
	e:SetSpecificLabel(ct+1,3)
	c:SetTurnCounter(ct+1)
	if c:GetTurnCounter()==2 then
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

--E2
function s.tdtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_GB,0,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,#g*800)
end
function s.tdop2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.Necro(Card.IsAbleToDeck),tp,LOCATION_GB,0,nil)
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 then
		local c=e:GetHandler()
		local ct=Duel.GetGroupOperatedByThisEffect(e):FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)
		if ct>0 and c:IsRelateToChain() and c:IsFaceup() then
			c:UpdateATK(ct*800,true,c)
		end
	end
end

--E3
function s.repfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_HERO) and not c:IsCode(id)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return e:IsCostChecked() and not c:HasFlagEffect(id+200) and Duel.IsExists(false,s.repfilter,tp,LOCATION_EXTRA,0,1,nil)
	end
	c:RegisterFlagEffect(id+200,RESETS_STANDARD_PHASE_END,0,1)
	local tc=Duel.Select(HINTMSG_CONFIRM,false,tp,s.repfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	e:SetLabelObject(tc)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc and c:IsRelateToChain() and c:IsFaceup() then
		local code=tc:GetOriginalCodeRule()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
		c:CopyEffect(tc:GetOriginalCode(),RESETS_STANDARD_PHASE_END,1)
	end
end

--E4
function s.bdcon(e)
	return not e:GetHandler():HasFlagEffect(id+100)
end