--Deptheaven Commons

Deptheaven=Deptheaven or {}

Deptheaven.Code = 0x249
function Deptheaven.Is(c, ignore_facedown)
	if (ignore_facedown==nil) then ignore_facedown=false end
	return c:IsSetCard(0x249) and (ignore_facedown or (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED+LOCATION_ONFIELD)))
end
function Deptheaven.LeftRightCheck(c) local seq=c:GetSequence() return seq==0 or seq==4 end
Deptheaven.LeftRightZones = 0x11

function Deptheaven.EnableAltSummon(c,exf,loc,filter)
	local code=c:GetOriginalCode()
	local oe1=Effect.CreateEffect(c)
	oe1:SetDescription(aux.Stringid(code,0))
	oe1:SetType(EFFECT_TYPE_FIELD)
	oe1:SetCode(EFFECT_SPSUMMON_PROC)
	oe1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	oe1:SetRange(LOCATION_EXTRA+LOCATION_GRAVE)
	oe1:SetCondition(Deptheaven.AltXyzCon(exf,filter,loc,code))
	oe1:SetTarget(Deptheaven.AltXyzTg(exf,filter,loc))
	oe1:SetOperation(Deptheaven.AltXyzOp(code))
	oe1:SetValue(SUMMON_TYPE_XYZ)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_EXTRA+LOCATION_GRAVE,0)
	e1:SetCondition(function(e) return Deptheaven.LeftRightCheck(e:GetHandler()) end)
	e1:SetTarget(function(e,c) return Deptheaven.Is(c) and c:IsType(TYPE_XYZ) end)
	e1:SetLabelObject(oe1)
	c:RegisterEffect(e1)
	return e1
end
function Deptheaven.AltMatFilter(c,xc,tp)
	return Deptheaven.Is(c) and c:IsCanBeXyzMaterial(xc)
end
function Deptheaven.AltXyzCon(exf,filter,loc,code)
	return function(e,c,og,min,max)
		if c==nil then return true end
		local tp=e:GetHandlerPlayer()
		local f=aux.TRUE
		if not Duel.IsExistingMatchingCard(exf,tp,0,LOCATION_MZONE,1,nil) then f=filter end
		return Duel.IsExistingMatchingCard(Deptheaven.AltMatFilter,tp,LOCATION_MZONE,0,1,nil,c,tp)
			and (Duel.IsExistingMatchingCard(f,tp,loc,0,1,c) or not c:IsLocation(LOCATION_EXTRA))
			and Duel.GetFlagEffect(tp,code)==0
	end
end
function Deptheaven.AltXyzMatGroupFilter(g,tp,loc)
	return g:Filter(Card.IsLocation,nil,LOCATION_MZONE):GetCount()<2 and g:Filter(Card.IsLocation,nil,loc):GetCount()<2
end
function Deptheaven.AltXyzTg(exf,filter,loc)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,c,og,min,max)
		local f
		if Duel.IsExistingMatchingCard(exf,tp,0,LOCATION_MZONE,1,nil) then f=aux.TRUE else f=filter end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local mg=Duel.GetMatchingGroup(Deptheaven.AltMatFilter,tp,LOCATION_MZONE,0,nil,c,tp)
		local sg
		if c:IsLocation(LOCATION_EXTRA) then
			mg:Merge(Duel.GetMatchingGroup(f,tp,loc,0,nil))
			local cancel=Duel.IsSummonCancelable()
			sg=mg:SelectSubGroup(tp,Deptheaven.AltXyzMatGroupFilter,cancel,2,2,tp,loc)
		else sg=mg:Select(tp,1,1,nil)
		end
		if sg then
			sg:KeepAlive()
			e:SetLabelObject(sg)
			return true
		else return false end
	end
end
function Deptheaven.AltXyzOp(code)
	return function(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
		local mg=e:GetLabelObject()
		local sg=Group.CreateGroup()
		local tc=mg:GetFirst()
		while tc do
			local sg1=tc:GetOverlayGroup()
			sg:Merge(sg1)
			tc=mg:GetNext()
		end
		Duel.SendtoGrave(sg,REASON_RULE)
		c:SetMaterial(mg)
		Duel.Overlay(c,mg)
		mg:DeleteGroup()
		Duel.RegisterFlagEffect(tp,code,RESET_PHASE+PHASE_END,0,1)
	end
end

function Deptheaven.EnableFastSummon(c,efilter,f,event)
	if (event==nil) then event=EVENT_CHAINING end
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(event)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(Deptheaven.FastSummonCon(efilter))
	e1:SetTarget(Deptheaven.FastSummonTarget)
	e1:SetOperation(Deptheaven.FastSummonOperation(f,c:GetOriginalCode()))
	c:RegisterEffect(e1)
	return e1
end
function Deptheaven.FastSummonCon(f)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return ep==Duel.GetTurnPlayer() and f(re,eg) and re:GetHandler()~=e:GetHandler()
	end
end
function Deptheaven.FastSummonFilter(c,e,tp)
	return Deptheaven.Is(c) and (bit.band(c:GetOriginalType(),TYPE_MONSTER)==TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function Deptheaven.FastSummonTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Deptheaven.FastSummonFilter,tp,LOCATION_SZONE+LOCATION_PZONE,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_SZONE+LOCATION_PZONE)
end
function Deptheaven.FastXyzFilter(c,f)
	return c:IsXyzSummonable(nil) and f(c)
end
function Deptheaven.FastSummonOperation(f,code)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,Deptheaven.FastSummonFilter,tp,LOCATION_SZONE+LOCATION_PZONE,0,1,1,nil,e,tp)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		and Duel.IsExistingMatchingCard(Deptheaven.FastXyzFilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,f)
		and Duel.SelectYesNo(tp,aux.Stringid(code,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local xg=Duel.SelectMatchingCard(tp,Deptheaven.FastXyzFilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,f)
			if #xg>0 then Duel.XyzSummon(tp,xg:GetFirst(),nil) end
		end
	end
end

Deptheaven.GYScaleProperty=EFFECT_FLAG_DELAY
function Deptheaven.EnableGYScale(c,tg,op)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(c:GetOriginalCode(),0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(Deptheaven.GYScaleProperty)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,c:GetOriginalCode())
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp~=Duel.GetTurnPlayer() end)
	e1:SetTarget(Deptheaven.GYScaleTarget(tg))
	e1:SetOperation(Deptheaven.GYScaleOperation(op))
	c:RegisterEffect(e1)
	return e1
end
function Deptheaven.GYScaleTarget(f)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
			and f(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		end
		f(e,tp,eg,ep,ev,re,r,rp,chk)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,0)
	end
end
function Deptheaven.GYScaleOperation(f)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then
			Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			f(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end

function Deptheaven.AddXyzRevive(c,con,f)
	--[[local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,c:GetOriginalCode())
	e1:SetCondition(Deptheaven.XyzReviveCon(con))
	e1:SetTarget(Deptheaven.XyzReviveTg(f))
	e1:SetOperation(Deptheaven.XyzReviveOp)
	c:RegisterEffect(e1)
	return e1]]
end

--[[function Deptheaven.XyzReviveCon(f)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		return c:IsPreviousLocation(LOCATION_ONFIELD) and Duel.GetTurnCount()==c:GetTurnID() and f(e,tp,eg,ep,ev,re,r,rp)
	end
end
function Deptheaven.XyzReviveTg(f)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) end
		local c=e:GetHandler()
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
			and Duel.IsExistingTarget(f,tp,LOCATION_GRAVE,0,1,c)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectTarget(tp,nil,tp,LOCATION_GRAVE,0,1,1,c)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
function Deptheaven.XyzReviveOp(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) and tc:IsRelateToEffect(e) then Duel.Overlay(c,tc) end
end]]

function Deptheaven.AddPendRestrict(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(Deptheaven.PendLimit)
	c:RegisterEffect(e1)
end
function Deptheaven.PendLimit(e,c,sump,sumtype,sumpos,targetp)
	return (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM and c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_HAND)
end

