--Un-Ionized Operator
--Operatore Un-Ionizzato
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,12)
	aux.EnableUnionAttribute(c,1)
	--[[ If this card becomes Engaged: Decrease this card's Energy by the number of Spells/Traps on the field.]]
	c:DriveEffect(0,0,nil,EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F,nil,EVENT_ENGAGE,
		nil,
		nil,
		nil,
		s.operation
	)
	--[[-5]: Equip to 1 Drive Monster you control, this Engaged card and 1 appopriate Equip Spell from your Deck,
	but banish 1 of these cards you equipped during the End Phase. If you control no Spells/Traps, you can activate this effect as a Quick Effect.]]
	c:DriveEffect(-5,1,CATEGORY_EQUIP,EFFECT_TYPE_IGNITION,nil,nil,
		s.eqcon,
		nil,
		s.eqtg,
		s.eqop
	)
	c:DriveEffect(-5,1,CATEGORY_EQUIP,EFFECT_TYPE_QUICK_O,nil,nil,
		aux.NOT(s.eqcon),
		nil,
		s.eqtg,
		s.eqop,
		false,
		false,
		true
	)
	--[[OD]: Target 1 face-up monster on the field; equip it to 1 Drive Monster you control as an Equip Spell that gives it 1000 ATK.]]
	c:OverDriveEffect(3,CATEGORY_EQUIP,EFFECT_TYPE_IGNITION,EFFECT_FLAG_CARD_TARGET,nil,
		s.eqcon,
		nil,
		s.eqtg2,
		s.eqop2
	)
	c:OverDriveEffect(3,CATEGORY_EQUIP,EFFECT_TYPE_QUICK_O,EFFECT_FLAG_CARD_TARGET,nil,
		aux.NOT(s.eqcon),
		nil,
		s.eqtg2,
		s.eqop2,
		false,
		false,
		true
	)
	--[[Once per turn, you can either: Target 1 face-up monster you control; equip this card to that target, OR: Unequip this card and Special Summon it.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(4)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.uniontg)
	e1:SetOperation(s.unionop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(5)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.disuniontg)
	e2:SetOperation(s.disunionop)
	c:RegisterEffect(e2)
	--[[While this card is equipped to a Drive Monster: You can add 1 Level 4 or lower Drive Monster from your Deck to your hand,
	and if you do, you can Engage it, and if you do that, you can increase or decrease its Energy by the original Energy of the Drive Monster this card is equipped to.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(6)
	e3:SetCategory(CATEGORIES_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:HOPT()
	e3:SetCondition(aux.IsEquippedToCond(aux.MonsterFilter(TYPE_DRIVE)))
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsEngaged() then
		local ct=Duel.GetMatchingGroupCount(Card.IsSpellTrapOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if ct>0 then
			c:UpdateEnergy(-ct,tp,REASON_EFFECT,true)
		end
	end
end

function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsSpellTrapOnField,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.eqmonster(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_DRIVE) and Duel.IsExistingMatchingCard(Card.IsAppropriateEquipSpell,tp,LOCATION_DECK,0,1,nil,c,tp)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>1 and c:IsEngaged() and c:CheckUniqueOnField(tp) and Duel.IsExistingMatchingCard(s.eqmonster,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,2,tp,c:GetLocation()|LOCATION_DECK)
	e:SetLabel(c:GetEngagedID())
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=1 or not c:IsRelateToChain() or not c:IsEngaged() or c:GetEngagedID()~=e:GetLabel() then return end
	local eqm=Duel.Select(HINTMSG_FACEUP,false,tp,s.eqmonster,tp,LOCATION_MZONE,0,1,1,nil,tp)
	if #eqm>0 then
		Duel.HintSelection(eqm)
		local eqtc=eqm:GetFirst()
		local eqg=Duel.Select(HINTMSG_EQUIP,false,tp,Card.IsAppropriateEquipSpell,tp,LOCATION_DECK,0,1,1,nil,eqtc,tp)
		eqg:AddCard(c)
		if #eqg==2 then
			local fid=c:GetFieldID()
			for tc in aux.Next(eqg) do
				local res=false
				if tc==c then
					res=Duel.EquipAndRegisterLimit(tp,tc,eqtc,true,true) 
				else
					if Duel.Equip(tp,tc,eqtc,true,true) and eqtc:GetEquipGroup():IsContains(tc) then
						res=true
					end
				end
				if res then
					tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,2))
				end
			end
			eqg:KeepAlive()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EVENT_PHASE|PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(eqg)
			e1:SetCondition(s.rmcon)
			e1:SetOperation(s.rmop)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
			Duel.EquipComplete()
		end
	end
end
function s.rmfilter(c,fid)
	return c:HasFlagEffectLabel(id,fid)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else
		return true
	end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	Duel.HintMessage(tp,HINTMSG_REMOVE)
	local tg=g:Filter(s.rmfilter,nil,e:GetLabel()):FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
	if #tg>0 then
		Duel.HintSelection(tg)
		if Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)>0 then
			g:DeleteGroup()
			e:Reset()
		end
	end
end

function s.eqfilter(c,tp)
	return c:IsFaceup() and (c:IsControler(tp) or c:IsAbleToChangeControler()) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_DRIVE),tp,LOCATION_MZONE,0,1,c)
end
function s.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.eqfilter(chkc,tp) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
	end
	local g=Duel.Select(HINTMSG_EQUIP,true,tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_EQUIP)
end
function s.eqop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local eqm=Duel.Select(HINTMSG_FACEUP,false,tp,aux.FaceupFilter(Card.IsType,TYPE_DRIVE),tp,LOCATION_MZONE,0,1,1,tc)
		if #eqm>0 then
			Duel.HintSelection(eqm)
			if Duel.EquipAndRegisterLimit(tp,tc,eqm:GetFirst()) then
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_EQUIP)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetValue(1000)
				e2:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
		end
	end
end

function s.filter(c)
	local ct1,ct2=c:GetUnionCount()
	return c:IsFaceup() and ct2==0
end
function s.uniontg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return c:GetFlagEffect(id)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_UNION|RESET_PHASE|PHASE_END,0,1)
end
function s.unionop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToChain() or c:IsFacedown() then return end
	if not tc:IsRelateToChain() or not s.filter(tc) then
		Duel.SendtoGrave(c,REASON_RULE)
		return
	end
	if not Duel.Equip(tp,c,tc,false) then return end
	aux.SetUnionState(c)
end
function s.disuniontg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:GetEquipTarget() and c:IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_UNION|RESET_PHASE|PHASE_END,0,1)
end
function s.disunionop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end

function s.scfilter(c)
	return c:IsMonster(TYPE_DRIVE) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.scfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.Search(g,tp)>0 and tc:IsLocation(LOCATION_HAND) and tc:IsCanEngage(tp) and c:AskPlayer(tp,STRING_ASK_ENGAGE) then
			tc:Engage(e,tp)
			if tc:IsEngaged() then
				local ec=c:GetEquipTarget()
				if ec and ec:IsMonster(TYPE_DRIVE) then
					local en=ec:GetOriginalEnergy()
					if en and tc:IsCanIncreaseOrDecreaseEnergy(en,tp,REASON_EFFECT) and c:AskPlayer(tp,STRING_ASK_UPDATE_ENERGY) then
						tc:IncreaseOrDecreaseEnergy(en,tp,REASON_EFFECT,true,c)
					end
				end
			end
		end
	end
end