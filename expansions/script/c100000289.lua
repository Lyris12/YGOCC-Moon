--[[
Dynastygian Scout - "Wyvern"
Esploratore Dinastigiana - "Viverna"
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
local FLAG_MUST_ACTIVATE = id+100

function s.initial_effect(c)
	--[[Each time a card(s) your opponent controls is destroyed, immediately gain 400 LP for each of those cards.]]
	aux.RegisterMaxxCEffect(c,id,nil,LOCATION_MZONE,EVENT_DESTROYED,s.reccon,s.recopOUT,s.recopIN,s.flaglabel)
	--[[During your Main Phase, if you control a "Dynastygian" Level 4 monster: You can Special Summon this card from your hand, and if you do,
	draw 1 card, then, if you drew a "Dynastygian" monster this way, you can Special Summon that monster.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORY_DRAW|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:HOPT()
	e2:SetFunctions(
		aux.LocationGroupCond(s.spcfilter,LOCATION_MZONE,0,1),
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e2)
	--[[When your opponent activates a card or effect on the field (Quick Effect): You can send 1 "Dynastygian" monster from your hand or field to the GY;
	negate the activation, and if you do, destroy that card, then, if you sent this card to the GY to activate this effect,
	Set 1 "Dynastygian" Trap directly from your hand or GY to either field. It can be activated this turn. (If you Set it to your opponent's field, they must activate it during the End Phase.)]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetCategory(CATEGORY_NEGATE|CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetFunctions(
		s.negcon,
		aux.ToGraveCost(s.negcfilter,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil,s.precost),
		s.negtg,
		s.negop
	)
	c:RegisterEffect(e3)
end
--E1
function s.cfilter(c,p)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(p)
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
function s.flaglabel(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.cfilter,nil,1-tp)
end
function s.recopOUT(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local ct=eg:FilterCount(s.cfilter,nil,1-tp)
	Duel.Recover(tp,ct*400,REASON_EFFECT)
end
function s.recopIN(e,tp,eg,ep,ev,re,r,rp,n)
	Duel.Hint(HINT_CARD,tp,id)
	local labels={Duel.GetFlagEffectLabel(tp,id)}
	local ct=0
	for i=1,#labels do
		ct=ct+labels[i]
	end
	Duel.Recover(tp,ct*400,REASON_EFFECT)
end

--E2
function s.spcfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_DYNASTYGIAN) and c:IsLevel(4)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.Draw(tp,1,REASON_EFFECT)>0 then
		local tc=Duel.GetGroupOperatedByThisEffect(e):GetFirst()
		if tc and s.spfilter(tc,e,tp) and Duel.GetMZoneCount(tp)>0 and Duel.SelectYesNo(tp,STRING_ASK_SPSUMMON) then
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_DYNASTYGIAN) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

--E3
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local trig_loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return rp==1-tp and trig_loc&LOCATION_ONFIELD>0 and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.negcfilter(c,e,tp)
	if not (c:IsFaceupEx() and c:IsMonster() and c:IsSetCard(ARCHE_DYNASTYGIAN)) then return false end
	if c==e:GetHandler() then
		return Duel.IsExists(false,s.setfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,c,tp)
	end
	return true
end
function s.setfilter(c,tp)
	return c:IsTrap() and c:IsSetCard(ARCHE_DYNASTYGIAN) and (c:IsSSetable(false,tp) or c:IsSSetable(false,1-tp))
end
function s.precost(g,e,tp,eg,ep,ev,re,r,rp)
	if g:IsContains(e:GetHandler()) then
		Duel.SetTargetParam(1)
	else
		Duel.SetTargetParam(0)
	end
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToChain(ev) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) and Duel.Destroy(eg,REASON_EFFECT)>0 and Duel.GetTargetParam()==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,aux.Necro(s.setfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,tp)
		if #g>0 then
			local tc=g:GetFirst()
			local checks={}
			for p=tp,1-tp,1-2*tp do
				local chk=tc:IsSSetable(false,p)
				table.insert(checks,chk)
			end
			local opt=aux.Option(tp,id,2,table.unpack(checks))
			if not opt then return end
			local setp=opt==0 and tp or 1-tp
			Duel.BreakEffect()
			if Duel.SSet(tp,tc,setp)>0 then
				local c=e:GetHandler()
				local og=g:Filter(aux.SetSuccessfullyFilter,nil)
				for oc in aux.Next(og) do
					local e1=Effect.CreateEffect(c)
					e1:SetDescription(STRING_FAST_ACTIVATION)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
					e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_CLIENT_HINT)
					e1:SetReset(RESET_EVENT|RESETS_STANDARD)
					oc:RegisterEffect(e1)
					if oc:IsControler(1-tp) then
						local eid=e:GetFieldID()
						oc:RegisterFlagEffect(FLAG_MUST_ACTIVATE,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,eid,aux.Stringid(id,4))
						local e2=Effect.CreateEffect(c)
						e2:SetDescription(id,5)
						e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
						e2:SetCode(EVENT_PHASE|PHASE_END)
						e2:OPT()
						e2:SetLabel(eid)
						e2:SetLabelObject(oc)
						e2:SetCondition(s.actcon)
						e2:SetOperation(s.actop)
						Duel.RegisterEffect(e2,1-tp)
					end
				end
			end
		end
	end
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	local eid=e:GetLabel()
	local tc=e:GetLabelObject()
	if not tc or not tc:HasFlagEffectLabel(FLAG_MUST_ACTIVATE,eid) then
		e:Reset()
		return false
	end
	return true
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local effect=tc:GetActivateEffect()
	if effect and effect:IsActivatable(tp) then
		Duel.Activate(effect)
	else
		Duel.Hint(HINT_CARD,tp,id)
		Duel.SendtoGrave(tc,REASON_RULE,PLAYER_NONE)
	end
	e:Reset()
end