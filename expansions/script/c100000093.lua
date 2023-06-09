--Trappit Carroturret
--Carotatorretta Trappolaniglio
--Scripted by: XGlitchy30

xpcall(function() require("expansions/script/glitchylib_core") end,function() require("script/glitchylib_core") end)

local s,id=GetID()
function s.initial_effect(c)
	--[[If exactly 1 monster is Normal or Flip Summoned, or Normal Set (except during the Damage Step): Reveal 1 "Trappit" monster in your hand, or that is Set on your field; apply 1 of these effects.
	● Immediately after this effect resolves, Normal Summon that revealed monster, and if you do, equip this card to it, also it gains 2000 ATK/DEF.
	● Flip Summon that revealed monster, and if you do, equip this card to it, also it gains 2000 ATK/DEF.]]
	aux.RegisterMergedDelayedEventGlitchy(c,id,{EVENT_SUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS,EVENT_MSET},s.egfilter,id)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_EQUIP|CATEGORY_ATKCHANGE|CATEGORY_DEFCHANGE)
	e1:SetCustomCategory(CATEGORY_ACTIVATES_ON_NORMAL_SET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:HOPT(true)
	e1:SetCost(aux.LabelCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate(0))
	c:RegisterEffect(e1)
	--[[If this face-up card you control leaves the field: You can add 1 "Trappit" card from your GY to your hand, except "Trappit Carroturret".]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:HOPT()
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--During your turn only, you can also activate this card from your hand.
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(aux.TurnPlayerCond(0))
	c:RegisterEffect(e3)
end

--Filters E1
function s.egfilter(c,_,_,eg,_,_,_,_,_,_,event)
	return #eg==1 and (c:IsSummonType(SUMMON_TYPE_NORMAL) or event==EVENT_FLIP_SUMMON_SUCCESS)
end
function s.rvfilter(c,e,tp,eg,ep,ev,re,r,rp)
	return c:IsMonster() and c:IsSetCard(ARCHE_TRAPPIT) and (c:IsSummonable(true,nil) or (c:IsCanBeFlipSummoned(tp,true) and aux.RemainOnFieldCost(e,tp,eg,ep,ev,re,r,rp,0)))
		and ((c:IsOnField() and c:IsFacedown()) or (c:IsLocation(LOCATION_HAND) and not c:IsPublic()))
end
	
--Text sections E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.rvfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil,e,tp,eg,ep,ev,re,r,rp)
	end
	e:SetLabel(0)
	local g=Duel.Select(HINTMSG_CONFIRM,false,tp,s.rvfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.ConfirmCards(1-tp,g)
		Duel.SetTargetCard(tc)
		if tc:IsLocation(LOCATION_HAND) then
			Duel.SetCardOperationInfo(g,CATEGORY_SUMMON)
			Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,1,tp,LOCATION_MZONE,2000)
			Duel.SetCustomOperationInfo(0,CATEGORY_DEFCHANGE,g,1,tp,LOCATION_MZONE,2000)
		else
			aux.RemainOnFieldCost(e,tp,eg,ep,ev,re,r,rp,chk)
			Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
		end
	end
end
function s.activate(mode)
	if mode==0 then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local tc=Duel.GetFirstTarget()
					if tc and tc:IsRelateToChain() then
						local c=e:GetHandler()
						local nscheck=(tc:IsLocation(LOCATION_HAND) or tc:IsFaceup()) and tc:IsSummonable(true,nil)
						local fscheck=tc:IsCanBeFlipSummoned(tp,true)
						if nscheck then
							local e1=Effect.CreateEffect(e:GetHandler())
							e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
							e1:SetCode(EVENT_SUMMON_SUCCESS)
							e1:SetLabelObject(tc)
							e1:SetOperation(function(_e,_tp,_eg,_ep,_ev,_re,_r,_rp)
								s.activate(1)(e,tp,eg,ep,ev,re,r,rp,_e)
								_e:Reset()
							end
							)
							e1:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD)
							tc:RegisterEffect(e1,true)
							Duel.Summon(tp,tc,true,nil)
							
						elseif fscheck then
							if Duel.FlipSummon(tp,tc) and c:IsRelateToChain() and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
								if tc:IsRelateToChain() and tc:IsFaceup() then
									if Duel.EquipAndRegisterLimit(tp,c,tc) then
										local e1=Effect.CreateEffect(c)
										e1:SetType(EFFECT_TYPE_EQUIP)
										e1:SetCode(EFFECT_IMMUNE_EFFECT)
										e1:SetValue(s.immval)
										e1:SetReset(RESET_EVENT|RESETS_STANDARD)
										c:RegisterEffect(e1)
										local e2=Effect.CreateEffect(c)
										e2:SetCategory(CATEGORY_DISABLE)
										e2:SetType(EFFECT_TYPE_QUICK_O)
										e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
										e2:SetCode(EVENT_FREE_CHAIN)
										e2:SetRange(LOCATION_SZONE)
										e2:SetHintTiming(0,RELEVANT_TIMINGS)
										e2:OPT()
										e2:SetCondition(aux.IsEquippedCond)
										e2:SetCost(aux.ToGraveCost(s.negcfilter),LOCATION_HAND|LOCATION_ONFIELD,0,1,1,true)
										e2:SetTarget(s.negtg)
										e2:SetOperation(s.negop)
										c:RegisterEffect(e2)
									end
								else
									c:CancelToGrave(false)
								end
							end
						end
					end
				end
	
	elseif mode==1 then
		return	function(e,tp,eg,ep,ev,re,r,rp,ce)
					local tc=ce:GetLabelObject()
					if tc and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) then
						tc:UpdateATKDEF(2000,2000,true,ce:GetOwner())
					end
				end
	end
end

--Immunity
function s.immval(e,re)
	if e:GetOwnerPlayer()==re:GetOwnerPlayer() then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g or not g:IsContains(e:GetHandler():GetEquipTarget())
end

--Negate
function s.negcfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_TRAPPIT)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DISABLE)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and aux.NegateMonsterFilter(tc) then
		Duel.Negate(tc,e)
	end
end

--Filters E2
function s.bfilter(c)
	return c:IsSetCard(ARCHE_TRAPPIT) and not c:IsCode(id) and c:IsAbleToHand()
end
--Text sections E2
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.bfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.bfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end