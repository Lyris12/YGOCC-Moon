--[[
Dynastygian Heavy Artillery - "Headbringer"
Artiglieria Pesante Dinastigiana - "Portateste"
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
local FLAG_MUST_ACTIVATE			= id
local FLAG_ONCE_PER_BATTLE_PHASE	= id+100

function s.initial_effect(c)
	--[[If you control no monsters, or if you control a DARK "Number" Xyz Monster: You can banish 1 "Dynastygian" Normal Trap from your GY, OR detach 1 material from a DARK "Number" Xyz Monster
	you control; Special Summon this card from your hand or GY, and if you do, Set up to 2 "Dynastygian" Normal Traps from your hand and/or Deck to either field. They can be activated this turn.
	(If a card(s) was Set to your opponent's field this way, your opponent must activate it during the End Phase. If they cannot, they send it to the GY instead)]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:HOPT()
	e1:SetFunctions(
		s.spcon,
		s.spcost,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[At the start of your Battle Phase, if your opponent's LP is 4000 or lower: You can activate this effect; other monsters you currently control cannot attack,
	except DARK "Number" Xyz Monsters, also DARK "Number" Xyz Monsters you currently control can attack your opponent directly.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE|PHASE_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:SetFunctions(
		s.atkcon,
		nil,
		s.atktg,
		s.atkop
	)
	c:RegisterEffect(e2)
end
--E1
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or Duel.IsExists(false,s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.cfilter(c,tp)
	if c:IsLocation(LOCATION_GRAVE) then
		return c:IsNormalTrap() and c:IsSetCard(ARCHE_DYNASTYGIAN) and c:IsAbleToRemoveAsCost()
	elseif c:IsLocation(LOCATION_MZONE) then
		return s.xyzfilter(c) and c:GetOverlayCount()>0 and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
	end
	return false
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,tp)
	end
	local tc=Duel.Select(HINTMSG_OPERATECARD,false,tp,s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc:IsLocation(LOCATION_GRAVE) then
		Duel.Remove(tc,POS_FACEUP,REASON_COST)
	else
		tc:RemoveOverlayCard(tp,1,1,REASON_COST)
	end
end
function s.setfilter(c,tp)
	return c:IsNormalTrap() and c:IsSetCard(ARCHE_DYNASTYGIAN) and (c:IsSSetable(false,tp) or c:IsSSetable(false,1-tp))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExists(false,s.setfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,tp)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.gcheck(ft)
	return	function(g,e,tp,mg,c)
				if #g==1 then return true end
				local ct={0,0}
				for tc in aux.Next(g) do
					for p=tp,1-tp,1-2*tp do
						if ft[p+1]-ct[p+1]>0 and tc:IsSSetable(true,p) then
							ct[p+1]=ct[p+1]+1
							break
						end
					end
				end
				return ct[1]+ct[2]==#g
			end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.Group(s.setfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,tp)
		if #g==0 then return end
		local ft1,ft2=Duel.GetLocationCount(tp,LOCATION_SZONE),Duel.GetLocationCount(1-tp,LOCATION_SZONE,tp)
		local ftsum=ft1+ft2
		if ftsum<=0 then return end
		local sg=aux.SelectUnselectGroup(g,e,tp,1,math.min(2,ftsum),s.gcheck({ft1,ft2}),1,tp,HINTMSG_SET)
		local eid=e:GetFieldID()
		local og=Group.CreateGroup()
		local onlyOne=#sg==1
		while #sg>0 do
			local tc=onlyOne and sg:GetFirst() or sg:Select(tp,1,1,nil):GetFirst()
			sg:RemoveCard(tc)
			local checks={}
			for p=tp,1-tp,1-2*tp do
				local chk=tc:IsSSetable(false,p)
				table.insert(checks,chk)
			end
			local opt=aux.Option(tp,id,2,table.unpack(checks))
			local setp=opt==0 and tp or 1-tp
			if Duel.SSet(tp,tc,setp)>0 and aux.SetSuccessfullyFilter(tc) then
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(STRING_FAST_ACTIVATION)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_CLIENT_HINT)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e1)
				if tc:IsControler(1-tp) then
					tc:RegisterFlagEffect(FLAG_MUST_ACTIVATE,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,eid,aux.Stringid(id,2))
					og:AddCard(tc)
				end
			end
		end
		if #og>0 then
			og:KeepAlive()
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(id,3)
			e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_PHASE|PHASE_END)
			e2:SetLabel(eid)
			e2:SetLabelObject(og)
			e2:SetCondition(s.actcon)
			e2:SetOperation(s.actop)
			Duel.RegisterEffect(e2,1-tp)
		end
	end
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	local eid=e:GetLabel()
	local g=e:GetLabelObject()
	if not g or #g==0 or not g:IsExists(Card.HasFlagEffectLabel,1,nil,FLAG_MUST_ACTIVATE,eid) then
		if g then g:DeleteGroup() end
		e:Reset()
		return false
	end
	return true
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local eid=e:GetLabel()
	local g=e:GetLabelObject():Filter(Card.HasFlagEffectLabel,nil,FLAG_MUST_ACTIVATE,eid)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	local effect=tc:GetActivateEffect()
	if effect and effect:IsActivatable(tp) then
		Duel.Activate(effect)
	else
		Duel.Hint(HINT_CARD,tp,id)
		Duel.SendtoGrave(tc,REASON_RULE,PLAYER_NONE)
	end
	tc:GetFlagEffectWithSpecificLabel(FLAG_MUST_ACTIVATE,eid,true)
end

--E2
function s.atkcon(e,tp)
	return Duel.IsTurnPlayer(tp) and Duel.GetLP(1-tp)<=4000
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return not c:HasFlagEffect(FLAG_ONCE_PER_BATTLE_PHASE) and Duel.IsExists(false,aux.TRUE,tp,LOCATION_MZONE,0,1,e:GetHandler()) and Duel.IsExists(false,s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	c:RegisterFlagEffect(FLAG_ONCE_PER_BATTLE_PHASE,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE,0,1)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.Group(aux.NOT(s.xyzfilter),tp,LOCATION_MZONE,0,aux.ExceptThis(c))
	local g2=Duel.Group(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g1) do
		tc:CannotAttack(nil,RESET_PHASE|PHASE_BATTLE,{c,true})
	end
	for tc in aux.Next(g2) do
		tc:CanAttackDirectly(nil,RESET_PHASE|PHASE_BATTLE,{c,true})
	end
end