--Gariscpa, il Fantasma Incatenato
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:HOPT()
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--equip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(aux.ProcSummonedCond)
	e2:SetTarget(s.eqtg(0))
	e2:SetOperation(s.eqop(0))
	c:RegisterEffect(e2)
	--substitute
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetTarget(s.desreptg)
	e3:SetOperation(s.desrepop)
	c:RegisterEffect(e3)
	--equip QE
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:HOPT()
	e4:SetCost(s.eqcost)
	e4:SetTarget(s.eqtg(LOCATION_GRAVE))
	e4:SetOperation(s.eqop(LOCATION_GRAVE))
	c:RegisterEffect(e4)
end
function s.spfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGraveAsCost() and c:IsFaceup()
end
function s.hspcon(e,c)
	if c==nil then return true end
	local eff={c:IsHasEffect(EFFECT_NECRO_VALLEY)}
	for _,te in ipairs(eff) do
		local op=te:GetOperation()
		if not op or op(e,c) then return false end
	end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil)
	return rg:CheckSubGroup(aux.mzctcheck,2,2,tp)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil)
	local g=rg:SelectSubGroup(tp,aux.mzctcheck,true,2,2,tp)
	if not g or #g<1 then return false end
	g:KeepAlive()
	e:SetLabelObject(g)
	return true
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end

function s.eqfilter(c,tp,f)
	return c:IsMonster() and f(c,RACE_ZOMBIE) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.eqtg(loc)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					return loc==0 or (e:GetHandler():IsLocation(LOCATION_MZONE) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp,Card.IsRace))
				end
				local p = loc==0 and tp or PLAYER_ALL
				Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,p,LOCATION_GRAVE)
				Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,p,LOCATION_GRAVE)
			end
end
function s.eqop(loc)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				if c:IsFacedown() or not c:IsRelateToChain(0) or Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
				local f = loc==0 and Card.IsOriginalRace or Card.IsRace
				local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE,loc,1,1,nil,tp,f):GetFirst()
				if tc then
					if not Duel.Equip(tp,tc,c) then return end
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
					e1:SetCode(EFFECT_EQUIP_LIMIT)
					e1:SetValue(s.eqlimit)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e1)
					if loc==0 then
						local e2=Effect.CreateEffect(c)
						e2:Desc(2)
						e2:SetType(EFFECT_TYPE_FIELD)
						e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
						e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
						e2:SetTargetRange(1,0)
						e2:SetTarget(s.sumlimit)
						e2:SetLabel(table.unpack({tc:GetCode()}))
						e2:SetReset(RESET_PHASE+PHASE_END)
						Duel.RegisterEffect(e2,tp)
					end
				end
			end
end
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
function s.sumlimit(e,c)
	local codes={e:GetLabel()}
	return c:IsCode(table.unpack(codes))
end

function s.repfilter(c,e)
	local ec=c:GetEquipTarget()
	return c:IsOriginalType(TYPE_MONSTER) and ec and ec==e:GetHandler() and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT) and not e:GetHandler():IsReason(REASON_REPLACE) and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
	local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e)
	if #g>0 then
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	end
	return false
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end

function s.costfilter(c)
	return c:IsMonster() and c:IsFaceupEx() and c:IsAbleToGraveAsCost()
end
function s.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,e:GetHandler())
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end