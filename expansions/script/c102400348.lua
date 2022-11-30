--created & coded by Lyris, art at https://www.zerochan.net/3071531
--機氷竜アードラ
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.mchk,2,true)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	c:RegisterEffect(e1)
	aux.AddContactFusionProcedure(c,s.mfilter(c:GetControler()),LOCATION_ONFIELD,0,Duel.Release,REASON_COST)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetTarget(s.lim)
	c:RegisterEffect(e4)
	if not s.global_check then
		s.global_check=true
		s[0]={}
		s[1]={}
		local rc=1
		while rc<RACE_ALL do
			s[0][rc]=0 s[1][rc]=0
			rc=rc<<1
		end
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.rchk)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_TURN_END)
		ge2:SetOperation(function() local rc=1 while rc<RACE_ALL do s[0][rc]=0 s[1][rc]=0 rc=rc<<1 end end)
		Duel.RegisterEffect(ge2,0)
	end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and aux.bpcon() end)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xd76))
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetCondition(function() return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL end)
	e4:SetTarget(function(e,tc) return Duel.GetAttacker()==tc and tc:IsSetCard(0xd76) end)
	e4:SetValue(500)
	c:RegisterEffect(e4)
end
function s.mchk(c,fc,sub,mg,sg)
	return (not sg or #(sg-c)==0 or sg:IsExists(function(tc) return c:IsAttribute(ATTRIBUTE_WATER) and tc:IsSetCard(0xd76) or c:IsSetCard(0xd76) and tc:IsAttribute(ATTRIBUTE_WATER) end,1,c)) and aux.drccheck(g)
end
function s.mfilter(tp)
	return  function(c)
				return Duel.GetReleaseGroup(tp):IsContains(c)
			end
end
function s.ctfilter(c,tp,rc)
	return c:IsSummonPlayer(tp) and c:IsRace(rc)
end
function s.rchk(e,tp,eg)
	for p=0,1 do if Duel.GetFlagEffect(p,id)>0 then
		local rc=1
		while rc<RACE_ALL do
			if eg:IsExists(s.ctfilter,1,nil,p,rc) then s[p][rc]=s[p][rc]+1 end
			rc=rc<<1
		end
	end end
end
function s.lim(e,c,sump,sumtype,sumpos,targetp)
	if sumpos and bit.band(sumpos,POS_FACEDOWN)>0 then return false end
	local tp=sump
	if targetp then tp=targetp end
	return s[tp][c:GetRace()] and s[tp][c:GetRace()]>1
end
