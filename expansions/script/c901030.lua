--I Tre Pentacoli di Argento Spektrale
--Scripted by: XGlitchy30
local s,id = GetID()

function s.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(s.rescon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--spsummon 3
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--check successful resolution
	if not s.global_check then
		s.global_check=true
		local g1=Effect.CreateEffect(c)
		g1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		g1:SetCode(EVENT_CHAINING)
		g1:SetOperation(s.chop1)
		Duel.RegisterEffect(g1,0)
		local g2=Effect.CreateEffect(c)
		g2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		g2:SetCode(EVENT_CHAIN_SOLVED)
		g2:SetOperation(s.chop2)
		Duel.RegisterEffect(g2,0)
		local g3=Effect.CreateEffect(c)
		g3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		g3:SetProperty(EFFECT_FLAG_DELAY)
		g3:SetCode(EVENT_CHAIN_END)
		g3:SetOperation(s.regop)
		g3:SetLabelObject(g2)
		Duel.RegisterEffect(g3,0)
		g1:SetLabelObject(g3)
		g2:SetLabelObject(g3)
	end
end
function s.chop1(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
function s.chop2(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasType(EFFECT_TYPE_ACTIONS) or not re:IsActiveType(TYPE_SPELL) or not re:GetHandler():IsSetCard(0x95) then return end
	e:SetLabel(rp)
	e:GetLabelObject():SetLabel(1)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()~=1 then return end
	local p=e:GetLabelObject():GetLabel()
	Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1)
end
function s.rescon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0
end

function s.rfilter(c,tp)
	return --[[c:IsCode(901019) and]] (c:IsControler(tp) or c:IsFaceup())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	local rg=Duel.GetReleaseGroup(tp):Filter(s.rfilter,nil,tp)
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,3,3,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,3,3,tp)
	aux.UseExtraReleaseCount(g,tp)
	Duel.Release(g,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ) and c:IsSetCard(0x48) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		return res and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local c=e:GetHandler()
		local tc=g:GetFirst()
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_BE_MATERIAL)
		e1:SetProperty(EFFECT_FLAG_EVENT_PLAYER+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCondition(s.efcon)
		e1:SetOperation(s.efop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_LEAVE)
		tc:RegisterEffect(e1,true)
		if not tc:IsType(TYPE_EFFECT) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_ADD_TYPE)
			e3:SetValue(TYPE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3,true)
		end
	end
end
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local no1,no2=c.xyz_number,rc.xyz_number
	if not no1 or not no2 or no1~=no2 then return false end
	return r==REASON_XYZ and rc:IsAttribute(ATTRIBUTE_DARK) and rc:IsType(TYPE_XYZ) and rc:IsSetCard(0x48) and rc:IsPreviousLocation(LOCATION_EXTRA) and rc:GetPreviousControler()==tp
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(3000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return s.rescon(e,tp,eg,ep,ev,re,r,rp) and aux.exccon(e) and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0
end
function s.ovfilter(c)
	return c:IsSetCard(0x27a) and c:IsCanOverlay()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return e:GetHandler():IsAbleToRemove() and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,3,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_DECK,0,3,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,3,3,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)>0 and c:IsLocation(LOCATION_REMOVED) then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<=0 then return end
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e):Filter(s.spfilter,nil,e,tp)
		if #g==0 or (#g>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return end
		if #g>ft then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			g=g:Select(tp,ft,ft,nil)
		end
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
			local fg=g:Filter(Card.IsLocation,nil,LOCATION_MZONE)
			local ag=Duel.GetMatchingGroup(s.ovfilter,tp,LOCATION_DECK,0,nil)
			if #ag<#fg then return end
			for tg in aux.Next(fg) do
				local oc=Duel.SelectMatchingCard(tp,s.ovfilter,tp,LOCATION_DECK,0,1,1,nil)
				if #oc>0 then
					Duel.Overlay(tg,oc:GetFirst())
				end
			end
		end		
	end
end