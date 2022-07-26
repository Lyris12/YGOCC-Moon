--created & coded by Lyris, art at https://www.zerochan.net/3071531
--機氷竜アードラ
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--aux.AddFusionProcFunRep(c,s.mchk,3,true)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	c:RegisterEffect(e1)
	--[[aux.AddContactFusionProcedure(c,Card.IsReleasable,LOCATION_HAND+LOCATION_ONFIELD,LOCATION_ONFIELD,Duel.Release,REASON_COST)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
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
	end]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	e3:SetValue(aux.TargetBoolFunction(s.filter,e3:GetHandlerPlayer()))
	c:RegisterEffect(e3)
end--[[
function s.read(c)
	if c:GetRank()>0 then return c:GetRank()
	else return c:GetLevel() end
end
function s.mchk(c,fc,sub,mg,sg)
	return (not sg or #(sg-c)<2
		or sg:IsExists(function(tc) return aux.gffcheck(Group.FromCards(c,tc),Card.IsSetCard,0xd76,Card.IsAttribute,ATTRIBUTE_WATER) end,1,c,sg)) and not sg:IsExists(Card.IsFusionType,1,nil,TYPE_LINK|TYPE_TIMELEAP)
		and sg:GetClassCount(s.read)==1 and aux.drccheck(g)
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
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then return end
	local rc=1
	while rc<RACE_ALL do s[tp][rc]=0 rc=rc<<1 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,2)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.lim)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
end
function s.lim(e,c,sump,sumtype,sumpos,targetp)
	if sumpos and bit.band(sumpos,POS_FACEDOWN)>0 then return false end
	local tp=sump
	if targetp then tp=targetp end
	return s[tp][c:GetRace()]>1
end]]
function s.filter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and c:IsSetCard(0xd76)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
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
