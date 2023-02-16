--Gardrenial Shears
local ref,id=GetID()
Duel.LoadScript("GardrenialCommons.lua")
function ref.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,ref.ffilter,2,true)
	--Duplicate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(ref.cptg)
	e1:SetOperation(ref.cpop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2)
	--Extra NS
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e3:SetCountLimit(1)
	e3:SetTarget(ref.sumtg)
	e3:SetOperation(ref.sumop)
	c:RegisterEffect(e3)
end
function ref.ffilter(c,fc,sub,mg,sg)
	return not sg or sg:FilterCount(aux.TRUE,c)==0
		or (c:IsRace(RACE_PLANT+RACE_INSECT)
		and sg:IsExists(Card.IsRace,1,c,c:GetRace()))
end

ref.plantchk=0
ref.insectchk=0
--Copy
function ref.cpfilter(c)
	return Gardenial.Is(c) and c:IsSpellTrap() and c:CheckActivateEffect(false,true,false)~=nil
end
function ref.PreAssume()
	ref.plantchk=Duel.GetFlagEffect(tp,Gardrenial.PlantID)
	ref.insectchk=Duel.GetFlagEffect(tp,Gardrenial.InsectID)
	Duel.RegisterFlagEffect(p,Gardrenial.PlantID,RESET_PHASE+PHASE_END,0,1,1)
	Duel.RegisterFlagEffect(p,Gardrenial.InsectID,RESET_PHASE+PHASE_END,0,1,1)
end
function ref.PostAssume()
	if ref.plantchk==0 then Duel.ResetFlagEffect(tp,Gardrenial.PlantID) end
	if ref.insectchk==0 then Duel.ResetFlagEffect(tp,Gardrenial.InsectID) end
end
function ref.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then ref.PreAssume()
		local res=chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and ref.cpfilter(chkc)
		ref.PostAssume()
		return res
	end
	if chk==0 then ref.PreAssume() 
		res=Duel.IsExistingTarget(ref.cpfilter,tp,LOCATION_GRAVE,0,1,nil) 
		ref.PostAssume()
		return res
	end
	ref.PreAssume()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,ref.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	ref.PosAssume()
end
function ref.cpop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e)) then return end
	ref.PreAssume()
	local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
	if not te then return end
	local tg=te:GetTarget()
	local op=te:GetOperation()
	if tg then tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,1) end
	Duel.BreakEffect()
	tc:CreateEffectRelation(te)
	Duel.BreakEffect()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	for etc in aux.Next(g) do
		etc:CreateEffectRelation(te)
	end
	if op then op(te,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,1) end
	tc:ReleaseEffectRelation(te)
	for etc in aux.Next(g) do
		etc:ReleaseEffectRelation(te)
	end
end

--Extra NS
function ref.sumfilter(c)
	return c:IsRace(RACE_INSECT+RACE_PLANT) and c:IsSummonable(true,nil)
end
function ref.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function ref.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,ref.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		Duel.Summon(tp,tc,true,nil)
		if not tc:IsLocation(LOCATION_MZONE) then return end
		local phase=Duel.GetCurrentPhase()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+phase)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabelObject(g:GetFirst())
		e1:SetCondition(ref.trcon)
		e1:SetOperation(ref.trop)
		Duel.RegisterEffect(e1,tp)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
function ref.trcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
function ref.trop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Release(tc,REASON_EFFECT)
end
