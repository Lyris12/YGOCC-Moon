--Ascend to the Deptheavens
local ref,id=GetID()
Duel.LoadScript("Deptheaven.lua")
function ref.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local oe1=Effect.CreateEffect(c)
	oe1:SetDescription(aux.Stringid(id,0))
	oe1:SetType(EFFECT_TYPE_FIELD)
	oe1:SetCode(EFFECT_SPSUMMON_PROC)
	oe1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	oe1:SetRange(LOCATION_EXTRA+LOCATION_GRAVE)
	oe1:SetCondition(ref.altcon)
	oe1:SetTarget(ref.alttg)
	oe1:SetOperation(Deptheaven.AltXyzOp(id))
	oe1:SetValue(SUMMON_TYPE_XYZ)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_EXTRA+LOCATION_GRAVE,0)
	e1:SetCondition(function(e) return Deptheaven.LeftRightCheck(e:GetHandler()) end)
	e1:SetTarget(function(e,c) return Deptheaven.Is(c) and c:IsType(TYPE_XYZ) end)
	e1:SetLabelObject(oe1)
	c:RegisterEffect(e1)
	Deptheaven.EnableFastSummon(c,ref.efilter,ref.rcfilter,EVENT_SPSUMMON_SUCCESS)
end
function ref.efilter(e,eg) return eg:IsExists(Card.IsAttackAbove,1,nil,2500) end
function ref.rcfilter(c) return c:IsRank(3,4,5) end
function ref.gfilter(g,tp,loc)
	return g:FilterCount(Card.IsControler,nil,1-tp)<2 and g:GetFirst():GetColumnGroup():IsContains(g:GetNext())
end

function ref.matfilter(c,tp)
	return Deptheaven.Is(c) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetColumnGroup():IsExists(aux.TRUE,1,c)
end
function ref.matgfilter(g,tp)
	return g:IsExists(ref.matfilter,1,nil,tp) and g:GetFirst():GetColumnGroup():IsContains(g:GetNext()) --g:GetClassCount(Card.GetColumnZone,LOCATION_ONFIELD)==1
end
function ref.altcon(e,c,og,min,max)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(ref.matfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		and Duel.GetFlagEffect(tp,id)==0
end
function ref.revfilter(c,tp)
	return c:GetColumnGroup():IsExists(ref.matfilter,1,c,tp)
end
function ref.alttg(e,tp,eg,ep,ev,re,r,rp,chk,c,og,min,max)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local mg=Duel.GetMatchingGroup(ref.matfilter,tp,LOCATION_MZONE,0,nil,tp)
	mg:Merge(Duel.GetMatchingGroup(ref.revfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tp))
	local cancel=Duel.IsSummonCancelable()
	local sg=mg:SelectSubGroup(tp,ref.matgfilter,cancel,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
