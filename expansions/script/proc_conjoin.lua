--created by Chahine, coded by Lyris
--Not yet finalized values
--Custom constants
EFFECT_CONJOINT_EVOLUTE_RATING	=394
TYPE_CONJOINT					=0x4000000000
TYPE_CUSTOM						=TYPE_CUSTOM|TYPE_CONJOINT
CTYPE_CONJOINT					=0x40
CTYPE_CUSTOM					=CTYPE_CUSTOM|CTYPE_CONJOINT

--Custom Type Table
Auxiliary.Conjoints={} --number as index = card, card as index = function() is_xyz

--overwrite functions
local get_type, get_orig_type, get_prev_type_field = 
Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField

Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Conjoints[c] then
		tpe=tpe|TYPE_CONJOINT
	end
	return tpe
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Conjoints[c] then
		tpe=tpe|TYPE_CONJOINT
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Conjoints[c] then
		tpe=tpe|TYPE_CONJOINT
	end
	return tpe
end

--Custom Functions
function Card.GetConjointNumber(c)
	if not Auxiliary.Conjoints[c] then return 0 end
	local te=c:IsHasEffect(EFFECT_CONJOINT_EVOLUTE_RATING)
	if c:IsLocation(LOCATION_OVERLAY) then return c:GetFlagEffectLabel(394) end
	if type(te:GetValue())=='function' then
		return te:GetValue()(te,c)
	else
		return te:GetValue()
	end
end
function Card.IsConjointedTo(c)
	return (c:GetFlagEffect(394)>0 or c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:GetOverlayTarget():IsType(TYPE_EVOLUTE)
end
function Auxiliary.AddOrigConjointType(c)
	table.insert(Auxiliary.Conjoints,c)
	Auxiliary.Customs[c]=true
	Auxiliary.Conjoints[c]=aux.TRUE
end
function Auxiliary.EnableConjointAttribute(c,ce)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CONJOINT_EVOLUTE_RATING)
	e1:SetValue(Auxiliary.CEVal(ce))
	c:RegisterEffect(e1)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetTarget(Auxiliary.DesRepDisjoint(ce))
	e5:SetOperation(function(e,tp) local tc=e:GetHandler() tc:RemoveEC(tp,math.min(ce,c:GetEC()),REASON_RULE) tc:RemoveOverlayCard(tp,1,1,REASON_RULE) end)
	c:RegisterEffect(e5)
	if c:IsType(TYPE_MONSTER) then
		e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_SPSUMMON_PROC_G)
		e3:SetRange(LOCATION_MZONE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCondition(Auxiliary.ConjointTarget)
		e3:SetOperation(Auxiliary.ConjointOp(ce))
		c:RegisterEffect(e3)
	else
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_MOVE)
		e2:SetOperation(Auxiliary.AddCE(ce))
		c:RegisterEffect(e2)
		e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_CHAIN_SOLVED)
		e3:SetRange(LOCATION_SZONE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e3:SetOperation(Auxiliary.STConjointOp(ce))
		c:RegisterEffect(e3)
	end
end
function Auxiliary.CEVal(ce)
	return	function(e,c)
				local ce=ce
				--insert modifications here
				return ce
			end
end
function Auxiliary.EvoluteFilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EVOLUTE) 
end
function Auxiliary.ConjointTarget(e,c,og)
	if c==nil then return true end
	local tp=c:GetControler()
	return c:GetFlagEffect(0)==0 and Duel.IsExistingMatchingCard(Auxiliary.EvoluteFilter,tp,LOCATION_MZONE,0,1,c)
end
function Auxiliary.ConjointOp(ce)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
				local g=Duel.SelectMatchingCard(tp,Auxiliary.EvoluteFilter,tp,LOCATION_MZONE,0,1,1,c)
				Duel.HintSelection(g+c)
				local tc=g:GetFirst()
				if c:GetOverlayCount()>0 then Duel.SendtoGrave(c:GetOverlayGroup(),REASON_RULE) end
				Duel.Overlay(tc,c)
				Auxiliary.AddCE(ce)(e,tp)
				if c:IsLocation(LOCATION_OVERLAY) and c:IsType(TYPE_EVOLUTE) then c:RegisterFlagEffect(394,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE,1,ce) end
				if tc:GetFlagEffect(2)==0 then
					tc:RegisterFlagEffect(2,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE,1)
					local e4=Effect.CreateEffect(c)
					e4:SetType(EFFECT_TYPE_FIELD)
					e4:SetCode(EFFECT_SPSUMMON_PROC_G)
					e4:SetRange(LOCATION_MZONE)
					e4:SetDescription(2)
					e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
					e4:SetCondition(Auxiliary.DisjointTarget)
					e4:SetOperation(Auxiliary.DisjointOp)
					e4:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e4)
				end
				c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			end
end
function Auxiliary.ConjointedFilter(c)
	return c:GetFlagEffect(0)==0 or c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function Auxiliary.DisjointTarget(e,c)
	if c==nil then return true end
	local g=c:GetOverlayGroup():Filter(Auxiliary.ConjointedFilter,nil)
	return #g>0 and (Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 or g:IsExists(Card.IsType,1,nil,TYPE_SPELL+TYPE_TRAP))
end
function Auxiliary.DisjointOp(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
	Duel.Hint(HINT_SELECTMSG,tp,12)
	local tc=c:GetOverlayGroup():FilterSelect(tp,Auxiliary.ConjointedFilter,1,1,nil):GetFirst()
	Duel.Hint(HINT_CARD,0,tc:GetOriginalCode())
	c:RemoveEC(tp,math.min(tc:GetConjointNumber(),c:GetEC()),REASON_RULE)
	if tc:IsType(TYPE_EFFECT) then
		sg:AddCard(tc)
		if c:IsType(TYPE_CONJOINT) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_SPSUMMON_SUCCESS)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return eg:IsExists(aux.FilterEqualFunction(Card.GetSummonLocation,LOCATION_OVERLAY),1,nil) end)
			e1:SetOperation(Auxiliary.SwapConjoint)
			c:RegisterEffect(e1)
		end
	else Duel.SendtoDeck(tc,nil,2,REASON_RULE) end
	tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
		e:Reset()
end
function Auxiliary.SwapConjoint(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.SelectEffectYesNo(tp,c) then return end
	local tc=eg:GetFirst()
	if c:GetOverlayCount()>0 then Duel.SendtoGrave(c:GetOverlayGroup(),REASON_RULE) end
	local cn=c:GetConjointNumber()
	Duel.Overlay(tc,c)
	if c:IsLocation(LOCATION_OVERLAY) then
		Auxiliary.AddCE(cn)(e,tp)
		c:RegisterFlagEffect(394,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE,1,cn)
		if tc:GetFlagEffect(2)==0 then
			tc:RegisterFlagEffect(2,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE,1)
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_FIELD)
			e4:SetCode(EFFECT_SPSUMMON_PROC_G)
			e4:SetRange(LOCATION_MZONE)
			e4:SetDescription(2)
			e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e4:SetCondition(Auxiliary.DisjointTarget)
			e4:SetOperation(Auxiliary.DisjointOp)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e4)
		end
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
	e:Reset()
end
function Auxiliary.AddCE(ce)
	return	function(e,tp)
				local c=e:GetHandler()
				if not c:IsLocation(LOCATION_OVERLAY) then return end
				local tc=c:GetOverlayTarget()
				if ce<tc:GetStage()-tc:GetEC() then
					tc:AddEC(ce,tp)
				else tc:RefillEC() end
			end
end
function Auxiliary.STConjointOp(ce)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				local ef=c:GetActivateEffect()
				if re~=ef or not c:IsRelateToEffect(ef)
					or not Duel.IsExistingMatchingCard(Auxiliary.EvoluteFilter,tp,LOCATION_MZONE,0,1,nil)
					or not Duel.SelectEffectYesNo(tp,e:GetHandler()) then return end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
				local g=Duel.SelectMatchingCard(tp,Auxiliary.EvoluteFilter,tp,LOCATION_MZONE,0,1,1,c)
				Duel.HintSelection(g+c)
				c:CancelToGrave()
				local cn=c:GetConjointNumber()
				local tc=g:GetFirst()
				Duel.Overlay(tc,c)
				Auxiliary.AddCE(ce)(e,tp)
				c:RegisterFlagEffect(394,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE,1,cn)
				if tc:GetFlagEffect(2)==0 then
					tc:RegisterFlagEffect(2,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE,1)
					local e4=Effect.CreateEffect(c)
					e4:SetType(EFFECT_TYPE_FIELD)
					e4:SetCode(EFFECT_SPSUMMON_PROC_G)
					e4:SetRange(LOCATION_MZONE)
					e4:SetDescription(2)
					e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
					e4:SetCondition(Auxiliary.DisjointTarget)
					e4:SetOperation(Auxiliary.DisjointOp)
					e4:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e4)
				end
				c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			end
end
function Auxiliary.DesRepDisjoint(ce)
	return function	(e,tp,eg,ep,ev,re,r,rp,chk)
				local c=e:GetHandler()
				if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:CheckRemoveOverlayCard(tp,1,REASON_RULE) end
				return Duel.SelectEffectYesNo(tp,c,96)
			end
end
