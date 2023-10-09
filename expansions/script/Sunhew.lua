--Shared Effects
Sunhew=Sunhew or {}
FLAG_WAS_ENGAGED = 28940280
EVENT_DISENGAGE = EVENT_CUSTOM+28940280
function Sunhew.EnableDisengage()
	if not disengage_global_check then
		--Debug.Message("Registering global check")
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(Sunhew.DisengageRegister)
		ge1:SetLabelObject(Group.CreateGroup())
		Duel.RegisterEffect(ge1,0)
		disengage_global_check = true
	end
end
function Sunhew.DisengageRegister(e,tp,eg)
	--Debug.Message("Checking...")
	local og=e:GetLabelObject()
	--Debug.Message(type(og))
	--Debug.Message(aux.GetValueType(og))

	local g=Duel.GetEngagedCards()
	g:KeepAlive()
	e:SetLabelObject(g)

	
	if not ((aux.GetValueType(og)=="Group") and (#og>0)) then return end
	--Debug.Message("Engaged Cards: "..#g.." Previously: "..#og)
		
	og:Sub(g)
	--if #og>0 then Debug.Message("A card left!") end

	local dc=og:GetFirst()
	while dc do
		--Debug.Message(dc:GetCode())
		Duel.RaiseSingleEvent(dc,EVENT_DISENGAGE,dc:GetReasonEffect(),dc:GetReason(),dc:GetReasonPlayer(),dc:GetReasonPlayer(),0)
		Duel.RaiseEvent(dc,EVENT_DISENGAGE,dc:GetReasonEffect(),dc:GetReason(),dc:GetReasonPlayer(),dc:GetReasonPlayer(),0)
		dc=og:GetNext()
	end

	og:DeleteGroup()
end
function Sunhew.Is(c,set)
	local code=c:GetCode()
	if not ((code>=28940280) and (code<=28940300)) then return false end
	return set or (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED+LOCATION_ONFIELD))
end

function Sunhew.Teach(e,tp,val)
	local ec=Duel.GetEngagedCard(tp)
	if ec~=nil and Sunhew.Is(ec) and ec:IsCanUpdateEnergy(val,tp,REASON_EFFECT)
	and Duel.SelectYesNo(tp,aux.Stringid(28940280,0)) then
		ec:UpdateEnergy(3,tp,REASON_EFFECT,true,e:GetHandler())
	end
end

function Sunhew.LeaveHandTemplate(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DISENGAGE)
	e1:SetCondition(Sunhew.LeaveHandCon)
	return e1
end
function Sunhew.LeftHandFilter(c,tp)
	return Sunhew.Is(c) and not c:IsLocation(LOCATION_HAND)
		and c:IsPreviousLocation(LOCATION_HAND) and c:GetPreviousControler()==tp
	--return c:IsPreviousLocation(LOCATION_HAND) and c:GetFlagEffect(FLAG_WAS_ENGAGED)>0
end
function Sunhew.LeaveHandCon(e,tp,eg)
	return eg:IsExists(Sunhew.LeftHandFilter,1,nil,tp)
end
function Sunhew.RegisterLeaveHandEffect(c,e)
	e:SetCode(EVENT_DISENGAGE)
	c:RegisterEffect(e)
	--[[local e1=e:Clone()
	e1:SetCode(EVENT_TO_DECK)
	c:RegisterEffect(e1)
	local t={EVENT_TO_GRAVE,EVENT_REMOVE,EVENT_SUMMON,EVENT_SPSUMMON,EVENT_MSET,EVENT_SSET}
	for i,code in pairs(t) do
		local ex=e1:Clone()
		ex:SetCode(code)
		c:RegisterEffect(ex)
	end]]
end