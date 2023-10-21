--created by Jake, coded by XGlitchy30
--Dawn Blader - Lion
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DDD)
	e1:SetCode(EVENT_DISCARD)
	e1:HOPT()
	e1:SetCondition(s.dsccond)
	e1:SetTarget(aux.SSSelfTarget())
	e1:SetOperation(aux.SSSelfOperation())
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SYNCHRO_LEVEL)
	e2:SetValue(s.lvval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(s.efcon)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3)
end
function s.dsccond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x613) and (c:IsReason(REASON_EFFECT) or (c:IsReason(REASON_COST) and re:IsActivated()))
end
function s.lvval(e,c)
	local lv=e:GetHandler():GetLevel()
	if c:IsRace(RACE_WARRIOR+RACE_DRAGON) then
		return 2*65536+lv
	else
		return lv
	end
end
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	return rc:IsRace(RACE_WARRIOR) and e:GetHandler():IsReason(REASON_SYNCHRO)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.nacon)
	e1:SetCost(aux.DiscardCost())
	e1:SetTarget(s.natg)
	e1:SetOperation(function() Duel.NegateAttack() end)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:Desc(3)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(function(ce,ctp,ceg,cep,cev,cre,cr,crp) Duel.NegateEffect(cev) end)
	rc:RegisterEffect(e2)
	rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
	aux.GainEffectType(rc,c)
end
function s.nacon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
function s.natg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id+1)==0 end
	c:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp~=tp and eg:IsContains(c) and Duel.IsChainDisablable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
