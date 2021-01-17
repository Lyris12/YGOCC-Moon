--coded by Lyris
--トクシーア召喚
--Not yet finalized values
--Custom constants
-- EFFECT_POTENCY=717
TYPE_TOXIA=0x400000000000
TYPE_CUSTOM=TYPE_CUSTOM|TYPE_TOXIA
CTYPE_TOXIA=0x4000
CTYPE_CUSTOM=CTYPE_CUSTOM|CTYPE_TOXIA

--Custom Type Table
Auxiliary.Toxias={} --number as index = card, card as index = function() is_xyz

--overwrite constants
TYPE_EXTRA=TYPE_EXTRA|TYPE_TOXIA

--overwrite functions
local get_type, get_orig_type, get_prev_type_field = 
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField

Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Toxias[c] then
		tpe=tpe|TYPE_TOXIA
		if not Auxiliary.Toxias[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	return tpe
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Toxias[c] then
		tpe=tpe|TYPE_TOXIA
		if not Auxiliary.Toxias[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Toxias[c] then
		tpe=tpe|TYPE_TOXIA
		if not Auxiliary.Toxias[c]() then
			tpe=tpe&~TYPE_XYZ
		end
	end
	return tpe
end

--Custom Functions
function Auxiliary.AddOrigToxiaType(c,isxyz)
	table.insert(Auxiliary.Toxias,c)
	Auxiliary.Customs[c]=true
	local isxyz=isxyz==nil and false or isxyz
	Auxiliary.Toxias[c]=function() return isxyz end
end
function Auxiliary.AddToxiaProc(c,potency,sac,req,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local ge2=Effect.CreateEffect(c)
	ge2:SetType(EFFECT_TYPE_FIELD)
	ge2:SetCode(EFFECT_SPSUMMON_PROC_G)
	ge2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	ge2:SetRange(LOCATION_EXTRA)
	ge2:SetCondition(Auxiliary.ToxiaCondition(req,...))
	ge2:SetOperation(Auxiliary.ToxiaOperation(potency,sac,req,...))
	c:RegisterEffect(ge2)
end
function Auxiliary.ToxiaCondition(req,...)
	local funs={...}
	return  function(e,c)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM+TYPE_RELAY) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				return req(e,tp,0,table.unpack(funs))
			end
end
function Auxiliary.ToxiaOperation(potency,sac,req,...)
	local funs={...}
	return  function(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
				req(e,tp,1,table.unpack(funs))
				if Duel.SetSummonCancelable then Duel.SetSummonCancelable(true) end
				Duel.ConfirmCards(tp,c)
				Duel.ConfirmCards(1-tp,c)
				local e0=sac(1-tp,potency)
				c:SetTurnCounter(0)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetCountLimit(1)
				e1:SetRange(LOCATION_EXTRA)
				e1:SetLabel(potency)
				e1:SetLabelObject(e0)
				e1:SetOperation(Auxiliary.ToxiaSummon)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,potency)
				c:RegisterEffect(e1)
				c:RegisterFlagEffect(CARD_PYRO_CLOCK,RESET_PHASE+PHASE_END,0,potency)
				_G["c"..c:GetOriginalCode()][c]=e1
			end
end
function Auxiliary.ToxiaSummon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==e:GetLabel() then
		if Duel.SpecialSummon(c,50,tp,tp,false,false,POS_FACEUP)~=0 then c:CompleteProcedure() end
		e:GetLabelObject():Reset()
	end
end
