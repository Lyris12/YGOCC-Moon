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
	aux.AddContactFusionProcedure(c,aux.FilterBoolFunction(aux.IsInGroup,Duel.GetReleaseGroup(c:GetControler(),true)),LOCATION_ONFIELD,0,Duel.Release,REASON_COST)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
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
	end
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(2)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	e3:SetValue(aux.TargetBoolFunction(s.filter,c:GetControler()))
	c:RegisterEffect(e3)
end
function s.mchk(c,fc,sub,mg,sg)
	return (not sg or #(sg-c)==0 or sg:IsExists(function(tc) return c:IsAttribute(ATTRIBUTE_WATER) and tc:IsSetCard(0xd76) or c:IsSetCard(0xd76) and tc:IsAttribute(ATTRIBUTE_WATER) end,1,c)) and aux.drccheck(g)
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
	return s[tp][c:GetRace()]>1
end
function s.filter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and c:IsSetCard(0xd76)
		and not c:IsReason(REASON_REPLACE)
end
function s.cfilter(c)
	return c:IsSetCard(0xd76) and c:IsAbleToRemove()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.filter,1,nil,tp) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	Duel.Hint(HINT_CARD,0,id)
end
