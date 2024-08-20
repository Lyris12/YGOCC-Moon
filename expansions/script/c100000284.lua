--[[
Scintillating Sorcerer
Stregone Scintillante
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If this card is Normal or Special Summoned: You can add 1 Spellcaster monster and 1 "Spellbook" Spell/Trap from your Deck or GY to your hand, except "Scintillating Sorcerer".]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--[[During the Main Phase (Quick Effect): You can reveal, from your hand, either 1 "Spellbook" Normal or Quick-Play Spell, or 1 "Spellbook" Normal Trap,
	that meets its activation requirement; banish that card, and if you do, this effect becomes that card's activation effect.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRelevantTimings()
	e2:HOPT()
	e2:SetFunctions(aux.MainPhaseCond(),aux.DummyCost,s.applytg,nil)
	c:RegisterEffect(e2)
	--[[Each time you activate a "Spellbook" Spell/Trap Card or effect, immediately after it resolves, all Spellcaster monsters you currently control gain 300 ATK/150 DEF
	until the end of their next next battle(s).]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_CREATED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.atkcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end

--E1
function s.thfilter1(c,tp)
	return c:IsMonster() and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand() and not c:IsCode(id)
		and Duel.IsExists(false,s.thfilter2,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,c)
end
function s.thfilter2(c)
	return c:IsST() and c:IsSetCard(ARCHE_SPELLBOOK) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.thfilter1,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter1),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tp)
	if #g1==0 then return end
	local g2=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter2),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,g1)
	g1:Merge(g2)
	if #g1==2 then
		Duel.Search(g1)
	end
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local eid,ogtype=e:GetLabel()
	local tc=e:GetLabelObject()
	if not tc:HasFlagEffectLabel(id,eid) then
		tc:SetCardData(CARDDATA_TYPE,ogtype)
		e:Reset()
	end
end

--E2
function s.applyfilter(c)
	return c:IsSetCard(ARCHE_SPELLBOOK) and (c:IsNormalSpell() or c:IsSpell(TYPE_QUICKPLAY) or c:IsNormalTrap()) and not c:IsPublic() and c:CheckActivateEffect(false,true,false)~=nil
end
function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then return e:IsCostChecked() and Duel.IsExists(false,s.applyfilter,tp,LOCATION_HAND,0,1,nil) end
	e:SetProperty(0)
	local g=Duel.Select(HINTMSG_CONFIRM,false,tp,s.applyfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.ConfirmCards(1-tp,g)
		local tc=g:GetFirst()
		local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
		Duel.ClearTargetCard()
		tc:CreateEffectRelation(e)
		local tg=te:GetTarget()
		e:SetProperty(te:GetProperty())
		if tg then tg(te,tp,ceg,cep,cev,cre,cr,crp,1) end
		e:SetCategory(CATEGORY_REMOVE)
		te:SetLabelObject(e:GetLabelObject())
		e:SetLabelObject(te)
		Duel.ClearOperationInfo(0)
		Duel.SetCardOperationInfo(tc,CATEGORY_REMOVE)
		e:SetOperation(s.applyop(tc))
	end
end
function s.applyop(tc)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				aux.OperationRegistrationProcedure(e,tp,eg,ep,ev,re,r,rp)
				if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
					local te=e:GetLabelObject()
					if te then
						e:SetLabelObject(te:GetLabelObject())
						local op=te:GetOperation()
						if op then
							op(te,tp,eg,ep,ev,re,r,rp)
						end
					end
				end
			end
end

--E3+E4
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp and re:IsActiveType(TYPE_ST) and re:GetHandler():IsSetCard(ARCHE_SPELLBOOK) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_FACEDOWN|RESET_CHAIN,0,1,Duel.GetCurrentChain())
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:HasFlagEffectLabel(id,Duel.GetCurrentChain())
end
function s.atkfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanUpdateStats(300,150,e,tp,REASON_EFFECT)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.atkfilter,tp,LOCATION_MZONE,0,nil,e,tp)
	if #g>0 then
		local c=e:GetHandler()
		Duel.Hint(HINT_CARD,0,id)
		for tc in aux.Next(g) do
			local e1,e2=tc:UpdateATKDEF(300,150,true,{c,true})
			e2:SetLabelObject(e1)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
			e3:SetCode(EVENT_DAMAGE_STEP_END)
			e3:SetOperation(s.resetop)
			e3:SetReset(RESET_EVENT|RESETS_STANDARD)
			e3:SetLabelObject(e2)
			tc:RegisterEffect(e3)
		end
	end
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local e2=e:GetLabelObject()
	local e1=e2:GetLabelObject()
	e2:Reset()
	e1:Reset()
	e:Reset()
end