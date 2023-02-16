--Symphaerie Conductor, Dridas
local ref,id=GetID()

if not zahl_override then --Special Material
	zahl_override=true
	card_get_synchro_level = Card.GetSynchroLevel
	Card.GetSynchroLevel = function(c,sc)
		local lv=card_get_synchro_level(c,sc)
		local egroup={sc:IsHasEffect(id+3)}
		for _,ce in ipairs(egroup) do
			if ce then
				local con,val=ce:GetTarget(),ce:GetValue()
				if con and con(c,sc) and val then return (val(c,sc)<<16)+lv end
			end
		end
		return lv
	end
end

function ref.initial_effect(c)
	--Synchro
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	local se=Effect.CreateEffect(c)
	se:SetType(EFFECT_TYPE_SINGLE)
	se:SetCode(id+3)
	se:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_UNCOPYABLE)
	se:SetTarget(function(c,sc) return c:IsSetCard(0x255) end)
	se:SetValue(function(c,sc) return 2 end)
	c:RegisterEffect(se)
	--Quick Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil) end)
	e1:SetTarget(ref.acttg)
	e1:SetOperation(ref.actop)
	c:RegisterEffect(e1)
	--Revive Proc
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,2})
	e2:SetCondition(ref.spcon)
	e2:SetTarget(ref.sptg)
	e2:SetOperation(ref.spop)
	c:RegisterEffect(e2)
end

--Quick Activate
function ref.actfilter(c)
	return c:IsSetCard(0x255) and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and c:IsFaceup() and c:CheckActivateEffect(false,true,false)~=nil
end
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then return Duel.IsExistingTarget(ref.actfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,ref.actfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function ref.actop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	if not te:GetHandler():IsRelateToEffect(e) then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_SEND_REPLACE)
	e1:SetTarget(ref.reptg)
	e1:SetValue(ref.repval)
	Duel.RegisterEffect(e1,tp)
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
	e1:Reset()
end
function ref.locmask(c)
	local loc=0
	if c:IsLocation(LOCATION_ONFIELD) then loc=LOCATION_ONFIELD end
	if c:IsLocation(LOCATION_HAND) then loc=LOCATION_HAND end
	if c:IsLocation(LOCATION_GRAVE) then loc=LOCATION_GRAVE end
	return loc
end
function ref.repfilter(c,tp)
	local dest=c:GetDestination()
	local loc=ref.locmask(c)
	return c:IsControler(tp) and (not c:IsReason(REASON_REPLACE)) and (dest==LOCATION_GRAVE or dest==LOCATION_REMOVED)
		and Duel.IsExistingMatchingCard(ref.reprfilter,tp,0,0xff,1,nil,loc,dest)
end
function ref.reprfilter(c,loc,dest)
	if not c:IsLocation(loc) then return false end
	if (dest==LOCATION_GRAVE) then return c:IsAbleToGrave() end
	if (dest==LOCATION_REMOVED) then return c:IsAbleToRemove() end
	return false
end
function ref.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(ref.repfilter,nil,tp)
	if chk==0 then return #g==#eg end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return false end
	local c=eg:GetFirst()
	while c do
		local dest=c:GetDestination()
		local hint
		if dest==LOCATION_GRAVE then hint=HINTMSG_TOGRAVE else hint=HINTMSG_REMOVE end
		Duel.Hint(HINT_SELECTMSG,tp,hint)
		local rg=Duel.SelectMatchingCard(tp,ref.reprfilter,tp,0,0xff,1,1,nil,ref.locmask(c),dest)
		if dest==LOCATION_GRAVE then Duel.SendtoGrave(rg,REASON_REPLACE+REASON_EFFECT)
			else Duel.Remove(rg,POS_FACEUP,REASON_REPLACE+REASON_EFFECT)
		end
		c=eg:GetNext()
	end
	--e:Reset()
	return true
end
function ref.repval(e,c)
	return ref.repfilter(c,c:GetControler())
end

--Revive Proc
function ref.spcfilter(c,tp) return ((c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup())
	or c:GetSummonLocation()==LOCATION_EXTRA) and c:IsReleasableByEffect()
end
function ref.spcgfilter(g,tp)
	return (g:FilterCount(Card.IsType,nil,TYPE_SPELL+TYPE_TRAP)<3)
		and (g:FilterCount(aux.FilterEqualFunction(Card.GetSummonLocation,LOCATION_EXTRA),nil)<2)
		and (g:FilterCount(Card.IsControler,nil,1-tp)<2)
end
function ref.spcon(e,c,og,min,max)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(ref.spcfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tp)
	return g:CheckSubGroup(ref.spcgfilter,3,3,tp)
end
function ref.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c,og,min,max)
	local sg=Group.CreateGroup()
	local mg=Duel.GetMatchingGroup(ref.spcfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tp)
	local cancel=Duel.IsSummonCancelable()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	sg=mg:SelectSubGroup(tp,ref.spcgfilter,cancel,3,3,tp)
	if sg and #sg>0 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function ref.spop(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
	local mg=e:GetLabelObject()
	c:SetMaterial(mg)
	Duel.Release(mg,REASON_COST)
	mg:DeleteGroup()
end
