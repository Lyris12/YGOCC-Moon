--SKILL: Soppressione della Fatica
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigSkillType(c)
	--ED Skill Properties
	aux.EDSkillProperties(c)
	--Fatigue Suppression
	local SKILL=Effect.CreateEffect(c)
	SKILL:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	SKILL:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	SKILL:SetRange(LOCATION_EXTRA)
	SKILL:SetCode(EVENT_PHASE+PHASE_BATTLE)
	SKILL:SetCountLimit(1)
	SKILL:SetCondition(cid.skillcon_skill)
	SKILL:SetOperation(cid.skillop)
	c:RegisterEffect(SKILL)
	--check destruction
	if not cid.global_check then
		cid.global_check=true
		cid[0]=false
		cid[1]=false
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DESTROYED)
		ge1:SetOperation(cid.check)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(cid.clear)
		Duel.RegisterEffect(ge2,0)
	end
end
--check destruction
function cid.check(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		cid[tc:GetPreviousControler()]=true
		tc=eg:GetNext()
	end
end
function cid.clear(e,tp,eg,ep,ev,re,r,rp)
	cid[0]=false
	cid[1]=false
end
--filters
function cid.filter(c,e,tp,tid)
	return bit.band(c:GetReason(),0x21)==0x21 and c:GetTurnID()==tid and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
--Fatigue Suppression
function cid.skillcon_skill(e,tp,eg,ep,ev,re,r,rp)
	return aux.skillcon(e) and Duel.GetFlagEffect(tp,id)<=0 and cid[tp] and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,Duel.GetTurnCount())
end
function cid.skillop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,Duel.GetTurnCount()) or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_CARD,1-tp,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,Duel.GetTurnCount())
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
			local e0=Effect.CreateEffect(e:GetHandler())
			e0:SetType(EFFECT_TYPE_SINGLE)
			e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e0:SetCode(EFFECT_UPDATE_ATTACK)
			e0:SetValue(1000)
			e0:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e0)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e3:SetValue(LOCATION_REMOVED)
			e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
			tc:RegisterEffect(e3,true)
			Duel.SpecialSummonComplete()
		end
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end