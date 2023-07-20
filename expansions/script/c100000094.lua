--Trappit Trojan Hare
--Lepre di Troia Trappolaniglio
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[Activate 1 of these effects, also, immediately after either of them resolves, your opponent Normal Summons/Sets 1 monster from their hand.
	● If exactly 1 monster is Normal or Flip Summoned, or Normal Set (except during the Damage Step): Add to the hand, 1 of your "Trappit" cards that is banished or in your GY,
	then you can reveal 1 other "Trappit" card in your hand, and if you do, draw 1 card.
	● If a monster(s) is Special Summoned on your opponent's field (except during the Damage Step): Special Summon to your opponent's field,
	1 of your "Trappit" monsters that is banished, in your Deck, or in your GY, and if you do,
	increase the Level of all monsters in your opponent's hand by the Level of that monster, until the end of this turn (even after they are Summoned/Set).]]
	aux.RegisterMergedDelayedEventGlitchy(c,id,{EVENT_SUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS,EVENT_MSET,EVENT_SPSUMMON_SUCCESS},s.egfilter,s.flags,nil,nil,nil,s.customev)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCustomCategory(CATEGORY_ACTIVATES_ON_NORMAL_SET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:HOPT(true)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate(0))
	c:RegisterEffect(e1)
	--During your turn only, you can also activate this card from your hand.
	local e2=Effect.CreateEffect(c)
	e2:Desc(4)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(aux.TurnPlayerCond(0))
	c:RegisterEffect(e2)
end
function s.egfilter(c,_,tp,eg,_,_,_,_,_,_,event)
	if event==EVENT_SPSUMMON_SUCCESS then
		return c:IsControler(1-tp)
	else
		return #eg==1 and (c:IsSummonType(SUMMON_TYPE_NORMAL) or event==EVENT_FLIP_SUMMON_SUCCESS)
	end
end
function s.flags(event)
	if not event then
		return id,id+100
	elseif event==EVENT_SPSUMMON_SUCCESS then
		return id+100
	else
		return id
	end
end
function s.customev(e,tp,eg,ep,ev,re,r,rp)
	local val=0
	if eg:IsExists(Card.HasFlagEffect,1,nil,id) then
		val=val|0x1
	end
	if eg:IsExists(Card.HasFlagEffect,1,nil,id+100) then
		val=val|0x2
	end
	return val
end

--Filters E1
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_TRAPPIT) and c:IsAbleToHand()
end
function s.rvfilter(c,codes)
	return c:IsSetCard(ARCHE_TRAPPIT) and not c:IsPublic() and not c:IsCode(table.unpack(codes))
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_TRAPPIT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
--Text sections E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1 = (ev&0x1==0x1 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GB,0,1,nil))
	local b2 = (ev&0x2==0x2 and Duel.GetMZoneCount(1-tp,nil,tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp))
	if chk==0 then
		return b1 or b2
	end
	local opt=aux.Option(tp,id,1,b1,b2)
	if opt==0 then
		e:SetCategory(CATEGORY_SUMMON|CATEGORY_TOHAND|CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GB)
	elseif opt==1 then
		e:SetCategory(CATEGORY_SUMMON|CATEGORY_SPECIAL_SUMMON)
	end
	Duel.SetTargetParam(opt)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,1-tp,LOCATION_HAND)
end
function s.activate(mode)
	if mode==0 then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local c=e:GetHandler()
					local opt=Duel.GetTargetParam()
					if opt==0 then
						local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_GB,0,1,1,nil)
						if #g>0 then
							local ct,ht=Duel.Search(g,tp)
							if ct>0 and ht>0 then
								local codes={g:GetFirst():GetCode()}
								Debug.Message(g:GetFirst():GetCode())
								local rg=Duel.Group(s.rvfilter,tp,LOCATION_HAND,0,nil,codes)
								if #rg>0 and Duel.IsPlayerCanDraw(tp,1) and c:AskPlayer(tp,3) then
									local sg=rg:Select(tp,1,1,nil)
									if #sg>0 then
										Duel.BreakEffect()
										Duel.ConfirmCards(1-tp,sg)
										Duel.Draw(tp,1,REASON_EFFECT)
									end
								end
							end
						end
						
					elseif opt==1 and Duel.GetMZoneCount(1-tp,nil,tp)>0 then
						local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
						if #g>0 and Duel.SpecialSummon(g,0,tp,1-tp,false,false,POS_FACEUP)>0 then
							if g:GetFirst():HasLevel() then
								local lv=g:GetFirst():GetLevel()
								local hg=Duel.GetHand(1-tp)
								local phase=Duel.GetCurrentPhase()
								if phase==PHASE_BATTLE_START or phase==PHASE_BATTLE_STEP then
									phase=PHASE_BATTLE
								end
								for tc in aux.Next(hg) do
									local e1=Effect.CreateEffect(c)
									e1:SetType(EFFECT_TYPE_SINGLE)
									e1:SetCode(EFFECT_UPDATE_LEVEL)
									e1:SetValue(lv)
									e1:SetReset(RESET_EVENT|(RESETS_STANDARD&(~RESET_TOFIELD))|RESET_PHASE|phase)
									tc:RegisterEffect(e1)
								end
								local e2=Effect.CreateEffect(c)
								e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
								e2:SetCode(EVENT_TO_HAND)
								e2:SetLabel(lv,phase)
								e2:SetOperation(s.hlvop)
								e2:SetReset(RESET_PHASE|phase)
								Duel.RegisterEffect(e2,tp)
							end
						end
					end
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
					e1:SetCode(EVENT_CHAIN_SOLVED)
					e1:SetLabelObject(e)
					e1:SetOperation(s.activate(1))
					e1:SetOwnerPlayer(1-tp)
					Duel.RegisterEffect(e1,1-tp)
				end
				
	elseif mode==1 then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					if re~=e:GetLabelObject() then return end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
					local g=Duel.SelectMatchingCard(tp,Card.IsSummonableOrSettable,tp,LOCATION_HAND,0,1,1,nil)
					local tc=g:GetFirst()
					if tc then
						Duel.SummonOrSet(tp,tc)
					end
					e:Reset()
				end
	end
end
function s.hlvfilter(c,tp)
	return c:IsLocation(LOCATION_HAND) and c:IsControler(tp)
end
function s.hlvop(e,tp,eg,ep,ev,re,r,rp)
	local lv,phase=e:GetLabel()
	local hg=eg:Filter(s.hlvfilter,nil,1-tp)
	for tc in aux.Next(hg) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT|(RESETS_STANDARD&(~RESET_TOFIELD))|RESET_PHASE|phase)
		tc:RegisterEffect(e1)
	end
end