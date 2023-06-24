--created & coded by Lyris, art from "The Star Dragon"
--ザ☆機夜光襲雷
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,3)
	local e1=c:DriveEffect(0,nil,nil,EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS,nil,EVENT_DESTROYED,nil,nil,nil,s.icop)
	local e2=c:DriveEffect(-1,0,CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON,EFFECT_TYPE_QUICK_O,EFFECT_FLAG_CARD_TARGET,nil,nil,nil,s.rvtg,s.rvop)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.descon)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
function s.cfilter(c)
	return c:GetOriginalType()&TYPE_MONSTER>0
end
function s.icop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(s.cfilter,nil)
	if c and c:IsEngaged() then
		c:UpdateEnergy(#g,tp,REASON_EFFECT)
	end
end
function s.filter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x7c4) and (not c:IsForbidden() and c:IsType(TYPE_PENDULUM)
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
		and not c:IsCode(id)
end
function s.rvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp)
		and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
end
function s.rvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or aux.NecroValleyNegateCheck(tc) or not aux.NecroValleyFilter()(tc) then return end
	local op=aux.SelectFromOptions(tp,{not tc:IsForbidden() and tc:IsType(TYPE_PENDULUM)
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1),1160},
		{Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false),1152})
	if op==1 then Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	else Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and Duel.GetAttackTarget()==e:GetHandler()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(300)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetTargetRange(0xff,0)
	e2:SetTarget(s.imtg)
	e2:SetValue(s.efilter)
	Duel.RegisterEffect(e2,tp)
end
function s.atktg(e,c)
	return c:IsSetCard(0x7c4) and (c:GetFlagEffect(id)==0 or c~=e:GetOwner())
end
function s.imtg(e,c)
	local ex,tg,ct,p,loc=Duel.GetOperationInfo(Duel.GetCurrentChain(),CATEGORY_DESTROY)
	local g=Group.CreateGroup()
	if tg then g=g+tg elseif ct==0 then return true end
	return c:IsSetCard(0x7c4) and (c:GetFlagEffect(id)==0 or c~=e:GetOwner()) and (not ex or not tg
		and not c:IsLocation(loc) and p~=PLAYER_ALL and not c:IsControler(p) or not tg:IsContains(c))
end
function s.efilter(e,re)
	return re:GetOwnerPlayer()==1-e:GetOwnerPlayer() and (not re:IsActivated()
		or not re:IsHasCategory(CATEGORY_DESTROY)
		or not Duel.GetOperationInfo(Duel.GetCurrentChain(),CATEGORY_DESTROY))
end
