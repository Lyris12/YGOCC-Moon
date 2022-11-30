--created & coded by Lyris, art at https://fanart.tv/movie/402980/wonders-of-the-arctic/?section=wallpaper
--機氷竜アークティック
local s,id,o=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(s.atkcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(aux.TRUE)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCost(s.cost)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		s[0]={}
		s[1]={}
		local race=1
		while race<RACE_ALL do
			s[0][race]=0
			s[1][race]=0
			race=race<<1
		end
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.rchk)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.cfilter(c,tp,rc)
	return c:IsSummonPlayer(tp) and c:IsRace(rc)
end
function s.rchk(e,tp,eg)
	for p=0,1 do if Duel.GetFlagEffect(p,id)>0 then
		local rc=1
		while rc<RACE_ALL do
			if eg:IsExists(s.cfilter,1,nil,p,rc) then s[p][rc]=s[p][rc]+1 end
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
function s.pfilter(c)
	return c:IsSetCard(0xd76) and c:IsPublic()
end
function s.atkcon(e)
	local tp=e:GetHandler():GetControler()
	local ct=Duel.GetMatchingGroupCount(s.pfilter,tp,LOCATION_HAND,0,nil)
	return not Duel.IsExistingMatchingCard(Card.IsAttackable,tp,0,LOCATION_MZONE,ct+1,nil)
end
function s.rfilter(c,e,tp)
	return c:IsSetCard(0xd76) and c:IsType(TYPE_MONSTER) and not c:IsPublic() and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetDescription(66)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst():RegisterEffect(e1)
end
function s.xfilter(c,code)
	return c:IsType(TYPE_MONSTER) and c:IsCode(code) and (c:IsPublic() or c:IsFaceup())
end
function s.filter(c,e,tp)
	return c:IsSetCard(0xd76) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not Duel.IsExistingMatchingCard(s.xfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil,c:GetCode())
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and (e:IsCostChecked()
		or Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFlagEffect(tp,id)==0 then
		local rc=1
		while rc<RACE_ALL do s[tp][rc]=0 rc=rc<<1 end
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,2)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.lim)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
	end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp),0,tp,tp,false,false,POS_FACEUP)
end
