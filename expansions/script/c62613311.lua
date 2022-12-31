--Karasu, Ali Nottesfumo della Decadenza
--Script by XGlitchy30
function c62613311.initial_effect(c)
	c:SetSPSummonOnce(62613311)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,c62613311.matfilter,1,1)
	--zone limit (not fully implemented, requires a core update)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_USE_MZONE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(62613310)
	e1:SetTargetRange(LOCATION_MZONE+LOCATION_SZONE+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_OVERLAY,LOCATION_MZONE+LOCATION_SZONE+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_OVERLAY)
	e1:SetTarget(c62613311.limittg)
	e1:SetValue(c62613311.limitzone)
	c:RegisterEffect(e1)
	--spsummon procs adjustments (not fully implemented, require a core update)
	local e0x=Effect.CreateEffect(c)
	e0x:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0x:SetCode(EVENT_ADJUST)
	e0x:SetRange(LOCATION_MZONE)
	e0x:SetOperation(c62613311.adjustop)
	c:RegisterEffect(e0x)
	local e0y=Effect.CreateEffect(c)
	e0y:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0y:SetCode(EVENT_CHAINING)
	e0y:SetRange(LOCATION_MZONE)
	e0y:SetCondition(c62613311.handlimitcon)
	e0y:SetOperation(c62613311.handlimit)
	c:RegisterEffect(e0y)
	--mill
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62613311,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,62613311)
	e2:SetCost(c62613311.tgcost)
	e2:SetTarget(c62613311.tgtg)
	e2:SetOperation(c62613311.tgop)
	c:RegisterEffect(e2)
end
c62613311.linklimitid=62613310+0
--filters
function c62613311.matfilter(c)
	return c:IsLinkSetCard(0x6233) and c:IsLinkType(TYPE_EFFECT) and not c:IsLinkType(TYPE_LINK)
end
function c62613311.flagcheck(c)
	return c:GetFlagEffect(62613311)<=0
end
function c62613311.flagcheck2(c)
	return c:GetFlagEffect(60613311)<=0 and c:IsType(TYPE_MONSTER) and not c:IsSetCard(0x6233)
end
function c62613311.cfilter(c,g)
	return c:IsFaceup() and c:IsSetCard(0x6233) and c:IsType(TYPE_XYZ)
		and g:IsContains(c) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function c62613311.tgfilter(c)
	return c:IsSetCard(0x6233) and c:IsAbleToGrave()
end
--zone limit
function c62613311.limittg(e,c)
	return c:IsType(TYPE_MONSTER) and not c:IsSetCard(0x6233)
end
function c62613311.limitzone(e,c,fp,rp,r)
	return ~(e:GetHandler():GetLinkedZone())
end				
--spsummon procs adjustments
function c62613311.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local cc=e:GetHandler()
	local p=cc:GetControler()
	if not cc:IsLocation(LOCATION_MZONE) or not cc:IsControler(p) then return end
	local g=Duel.GetMatchingGroup(c62613311.flagcheck,tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED+LOCATION_OVERLAY+LOCATION_DECK,0,nil)
	if g:GetCount()<=0 then return end
	for rc in aux.Next(g) do
		if rc:GetFlagEffect(62613311)<=0 then
			rc:RegisterFlagEffect(62613311,RESET_EVENT+EVENT_CUSTOM+62613311,EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
			local m=_G["c"..rc:GetOriginalCode()]
			if not m then return false end
			local egroup=m.default_call_table
			if egroup~=nil then
				for cte=1,#egroup do
					local ce=egroup[cte]
					if ce and ce:GetCode()==EFFECT_SPSUMMON_PROC then
						local val=ce:GetValue()
						if aux.CheckKaijuProc(ce) then
							ce:SetValue(function (e,c)
											if type(val)~='number' then
												local a1,seq=val(e,c)
												if c:IsSetCard(0x6233) then
													return a1,seq
												else
													return a1,seq&(~cc:GetLinkedZone(1-c:GetControler()))
												end
											else
												if c:IsSetCard(0x6233) then
													return val
												else
													return val,~cc:GetLinkedZone(1-c:GetControler())
												end
											end
										end
										)
						else
							ce:SetValue(function (e,c)
											if type(val)~='number' then
												local a1,seq=val(e,c)
												if c:IsSetCard(0x6233) then
													return a1,seq
												else
													return a1,seq&(~cc:GetLinkedZone(c:GetControler()))
												end
											else
												if c:IsSetCard(0x6233) then
													return val
												else
													return val,~cc:GetLinkedZone(c:GetControler())
												end
											end
										end
										)
						end
						local reset=Effect.CreateEffect(cc)
						reset:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
						reset:SetProperty(EFFECT_FLAG_DELAY)
						reset:SetCode(EVENT_ADJUST)
						reset:SetLabel(p)
						reset:SetCountLimit(1)
						reset:SetCondition(c62613311.resetcostcon)
						reset:SetOperation(aux.ResetEffectFunc(ce,'value',val))
						Duel.RegisterEffect(reset,tp)
						local reset2=reset:Clone()
						reset2:SetLabelObject(rc)
						reset2:SetOperation(c62613311.resetflag)
						Duel.RegisterEffect(reset2,tp)
					end
				end
			end
		end
	end
end
function c62613311.resetcostcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsFaceup() or not c:IsLocation(LOCATION_MZONE) or not c:IsControler(e:GetLabel())
end
function c62613311.resetflag(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	if c:GetFlagEffect(62613311)>0 then
		c:ResetFlagEffect(62613311)
	end
	e:Reset()
end
function c62613311.handlimitcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasCategory(CATEGORY_SPECIAL_SUMMON)
end
function c62613311.handlimit(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_MUST_USE_MZONE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetLabel(62613310)
	e1:SetTarget(c62613311.limittg)
	e1:SetValue(c62613311.limitzone)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
end
--mill
function c62613311.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	if chk==0 then return Duel.CheckReleaseGroup(tp,c62613311.cfilter,1,nil,lg) end
	local g=Duel.SelectReleaseGroup(tp,c62613311.cfilter,1,1,nil,lg)
	Duel.Release(g,REASON_COST)
end
function c62613311.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c62613311.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c62613311.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c62613311.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end